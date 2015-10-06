module Spree
  class Gateway
    class BraintreeVzero
      class Utils

        attr_reader :order, :customer, :gateway

        def initialize(gateway, order)
          @order = order
          begin
            @customer = gateway.provider::Customer.find(order.user.id) if order.user
          rescue
          end
          @gateway = gateway
        end


        def get_address(address_type)
          if order.user && address = order.user.send("#{address_type}_address")
            braintree_address = BraintreeVzero::Address.new(gateway.provider, order.user, order)
            if address.braintree_id && braintree_address.find(address.braintree_id)
              {"#{address_type}_address_id" => braintree_address.id}
            else
              {address_type => address_data(address_type)}
            end
          else
            {address_type => address_data(address_type)}
          end
        end

        def get_customer
          if @customer
            {customer_id: @customer.id}
          else
            {customer: (payment_in_vault[:store_shipping_address_in_vault] && order.user) ? customer_data(order.user) : {}}
          end
        end

        def order_data(nonce)
          {
            amount: order.total,
            payment_method_nonce: nonce,
            order_id: order.number
          }
        end

        def address_data(address_type)
          {
            company: order.send("#{address_type}_address").company,
            country_code_alpha2: order.send("#{address_type}_address").country.iso,
            country_code_alpha3: order.send("#{address_type}_address").country.iso3,
            country_code_numeric: order.send("#{address_type}_address").country.numcode,
            country_name: order.send("#{address_type}_address").country.name,
            first_name: order.send("#{address_type}_address").first_name,
            last_name: order.send("#{address_type}_address").last_name,
            locality: order.send("#{address_type}_address").city,
            postal_code: order.send("#{address_type}_address").zipcode,
            region: order.send("#{address_type}_address").state.try(:abbr),
            street_address: order.send("#{address_type}_address").address1,
            extended_address: order.send("#{address_type}_address").address2
          }
        end

        def customer_data(user)
          address_data('billing').slice(:first_name, :last_name, :company, :phone).merge!(id: user.id, email: user.email)
        end

        def payment_in_vault
          if gateway.preferred_store_payments_in_vault == 'store_only_on_success'
            {store_in_vault_on_success: true, store_shipping_address_in_vault: true}
          elsif gateway.preferred_store_payments_in_vault == 'store_all'
            {store_in_vault: true, store_shipping_address_in_vault: true}
          else
            {store_in_vault: false}
          end
        end

        def map_payment_status(braintree_status)
          case braintree_status
            when 'authorized'
              'pending'
            when 'voided'
              'void'
            when 'submitted_for_settlement', 'settling', 'settlement_pending'
              'pending'
            when 'settled'
              'completed'
            else
              'failed'
          end
        end

      end
    end
  end
end