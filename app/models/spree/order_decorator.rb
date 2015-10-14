Spree::Order.class_eval do
  def save_paypal_address(type, address_hash)
    return if address_hash.blank?

    update("#{type}_id" => Spree::Address.create(prepare_address_hash(address_hash)).id)
  end

  private

  def prepare_address_hash(hash)
    country_id = Spree::Country.find_by(iso: hash.delete(:country)).id

    hash[:country_id] = country_id
    hash[:state_id] = Spree::State.find_by(abbr: hash.delete(:state), country_id: country_id).id

    return hash if hash[:full_name].blank?

    full_name = hash.delete(:full_name).split(' ')
    hash[:lastname] = full_name.slice!(-1)
    hash[:firstname] = full_name.join(' ')
    hash
  end
end
