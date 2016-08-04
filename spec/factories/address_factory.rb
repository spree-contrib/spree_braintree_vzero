FactoryGirl.modify do
  factory :address, aliases: [:bill_address, :ship_address], class: Spree::Address do
    firstname 'John'
    lastname 'Doe'
    address1 '10 Lovely Street'
    city 'Adamsville'
    zipcode '35005'
    phone '123-456-7890'

    state { |address| address.association(:state) }
    country do |address|
      if address.state
        address.state.country
      else
        address.association(:country)
      end
    end
  end
end
