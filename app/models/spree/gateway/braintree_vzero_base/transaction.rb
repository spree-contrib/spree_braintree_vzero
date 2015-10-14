module Spree
  class Gateway
    class BraintreeVzeroBase
      class Transaction

        attr_reader :transaction_id, :request

        def initialize(provider, transaction_id=nil)
          @transaction_id = transaction_id
          @request = provider::Transaction
        end

        def submit_for_settlement(amount)
          @request.submit_for_settlement(transaction_id, amount)
        end

        def clone
          t = @request.find(transaction_id)
          sale(payment_method_token: t.credit_card_details.token, amount: t.amount, options: {submit_for_settlement: true})
        end

        def sale(data)
          @request.sale(data)
        end

        def status
          @request.find(transaction_id).status
        end

        def void
          @request.void(transaction_id)
        end

        def refund(cents)
          @request.refund(transaction_id, cents)
        end

      end
    end
  end
end