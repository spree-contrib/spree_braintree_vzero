module Spree
  class Gateway
    class BraintreeUtils

      attr_reader :order

      def initialize(order)
        @order = order
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
          extended_address: order.send("#{address_type}_address").address2,
        }
      end

    end
  end
end
