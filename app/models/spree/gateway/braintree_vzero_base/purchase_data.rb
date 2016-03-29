module Spree
  class Gateway
    class BraintreeVzeroBase
      module PurchaseData
        extend ActiveSupport::Concern

        private

        def set_purchase_data(identifier_hash, order, money_in_cents, source)
          data = set_basic_purchase_data(identifier_hash, order, @utils, money_in_cents)
          data = set_merchant_account_id(data, order) if preferences[:currency_merchant_accounts]
          data.merge!(
            descriptor: { name: preferred_descriptor_name.to_s.gsub('/', '*') },
            options: {
              submit_for_settlement: auto_capture?,
              add_billing_address_to_payment_method: preferred_pass_billing_and_shipping_address ? true : false,
              three_d_secure: {
                required: (try(:preferred_3dsecure) unless source.admin_payment?)
              }
            }.merge!(@utils.payment_in_vault(data))
          )
          return data if source.admin_payment? || !preferred_advanced_fraud_tools
          data.merge!(device_data: source.advanced_fraud_data)
        end

        def set_basic_purchase_data(identifier_hash, order, utils, money_in_cents)
          data = { channel: I18n.t('braintree.channel_parameter') }
          data.merge!(utils.get_customer)
          data.merge!(utils.order_data(identifier_hash, money_in_cents.to_f / 100))
          return data unless preferred_pass_billing_and_shipping_address

          data.merge!(utils.get_address('billing')) unless order.shipping_address.same_as?(order.billing_address)
          data.merge!(utils.get_address('shipping'))
        end

        def set_merchant_account_id(data, order)
          account_id = preferred_currency_merchant_accounts[order.currency]
          return data unless account_id
          data.merge(merchant_account_id: account_id)
        end

        def order_data_from_options(options)
          order_number, payment_number = options[:order_id].split('-')
          order = Spree::Order.find_by(number: order_number)
          payment = order.payments.find_by(identifier: payment_number)
          [order, payment]
        end
      end
    end
  end
end
