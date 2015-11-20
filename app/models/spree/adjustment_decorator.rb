Spree::Adjustment.class_eval do
  after_save :set_eligibility

  private

  def set_eligibility
    return unless mandatory
    update_column(:eligible, true)
  end
end
