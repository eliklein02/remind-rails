# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
50.times do
  Contact.create!(
    organization_id: 1,
    name: "#{Faker::Name.male_first_name} #{Faker::Name.last_name}",
    phone: Faker::PhoneNumber.cell_phone,
    year_entered: Faker::Date.between(from: '2014-09-23', to: '2014-09-23'),
    year_left: Faker::Date.between(from: '2016-09-23', to: '2016-09-23'),
    opted_in_status: 1
  )
end

50.times do
  Contact.create!(
    organization_id: 1,
    name: "#{Faker::Name.male_first_name} #{Faker::Name.last_name}",
    phone: Faker::PhoneNumber.cell_phone,
    year_entered: Faker::Date.between(from: '2015-09-23', to: '2015-09-23'),
    year_left: Faker::Date.between(from: '2017-09-23', to: '2017-09-23'),
    opted_in_status: 1

  )
end

50.times do
  Contact.create!(
    organization_id: 1,
    name: "#{Faker::Name.male_first_name} #{Faker::Name.last_name}",
    phone: Faker::PhoneNumber.cell_phone,
    year_entered: Faker::Date.between(from: '2016-09-23', to: '2016-09-23'),
    year_left: Faker::Date.between(from: '2018-09-23', to: '2018-09-23'),
    opted_in_status: 1

  )
end
