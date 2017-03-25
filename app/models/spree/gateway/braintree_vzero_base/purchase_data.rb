module Spree
  class Gateway
    class BraintreeVzeroBase
      module PurchaseData
        extend ActiveSupport::Concern

        private

        def set_purchase_data(identifier_hash, order, money_in_cents, source)
          data = set_basic_purchase_data(identifier_hash, order, @utils, money_in_cents)
          merchant_account_id = get_merchant_account(order.currency)
          data[:merchant_account_id] = merchant_account_id if merchant_account_id
          data[:descriptor] = { name: preferred_descriptor_name.to_s.tr('/', '*') }
          data[:options] = {
            submit_for_settlement: auto_capture?,
            add_billing_address_to_payment_method: preferred_pass_billing_and_shipping_address ? true : false,
            three_d_secure: {
              required: (try(:preferred_3dsecure) unless source.admin_payment?)
            }
          }.merge!(@utils.payment_in_vault(data))
          return data if source.admin_payment? || !preferred_advanced_fraud_tools
          data.merge!(device_data: source.advanced_fraud_data)
        end

        def set_basic_purchase_data(identifier_hash, order, utils, money_in_cents)
          data = { channel: I18n.t('braintree.channel_parameter') }
          data.merge!(utils.get_customer)
          data.merge!(utils.order_data(identifier_hash, money_in_cents.to_f / 100))
          return data unless preferred_pass_billing_and_shipping_address

          data.merge!(utils.get_address('billing'))
          data.merge!(utils.get_address('shipping'))
        end

        def get_merchant_account(currency)
          preferred_currency_merchant_accounts[currency]
        end

        def order_data_from_options(options)
          order_number, payment_number = options[:order_id].split('-')
          order = Spree::Order.find_by(number: order_number)
          payment = order.payments.find_by(number: payment_number)
          [order, payment]
        end
      end
    end
  end
end
