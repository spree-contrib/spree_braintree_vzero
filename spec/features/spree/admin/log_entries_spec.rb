require 'spec_helper'

describe 'Log entries', :vcr, type: :feature do
  include Spree::BaseHelper

  stub_authorization!

  let(:payment) { order.payments.last }
  let(:entry) { payment.log_entries.last }
  let(:message) { entry.parsed_details.message }

  context 'with a successful log entry' do
    let!(:order) do
      order = OrderWalkthrough.up_to(:payment)
      order.payments << create(:braintree_vzero_paypal_payment, order: order)
      order.next!
      order.next
      order
    end

    it 'shows a successful attempt' do
      expect(message).to be_blank

      visit spree.admin_order_payments_path(order)
      find("#payment_#{payment.id} a").click
      click_link 'Logs'
      within('#listing_log_entries') do
        expect(page).to have_css('.log_entry.success')
        expect(page).not_to have_css('.log_entry.fail')
        expect(page).to have_content(pretty_time(entry.created_at))
      end
    end
  end

  context 'with a failed log entry' do
    let!(:order) do
      order = OrderWalkthrough.up_to(:payment)
      order.payments << create(:braintree_vzero_failed_paypal_payment, order: order)
      order.next!
      order.next
      order
    end

    it 'shows a failed attempt' do
      expect(message).to be_present

      visit spree.admin_order_payments_path(order)
      find("#payment_#{payment.id} a").click
      click_link 'Logs'
      within('#listing_log_entries') do
        expect(page).not_to have_css('.log_entry.success')
        expect(page).to have_css('.log_entry.fail')
        expect(page).to have_content(pretty_time(entry.created_at))
        expect(page).to have_content(message)
      end
    end
  end
end
