# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "Seeding database..."

# Create sample customer
customer = User.find_or_create_by!(email: "customer@example.com") do |u|
  u.name = "Sample Customer"
  u.password = "password123"
  u.role = :customer
end
puts "Created customer: #{customer.email}"

# Create sample driver
driver = User.find_or_create_by!(email: "driver@example.com") do |u|
  u.name = "Sample Driver"
  u.password = "password123"
  u.role = :driver
end
puts "Created driver: #{driver.email}"

# Create driver profile with San Francisco location
unless driver.driver_profile
  profile = driver.create_driver_profile!(
    vehicle_type: :car,
    is_available: true,
    radius_preference: 15000
  )
  profile.set_location(37.7749, -122.4194) # San Francisco
  profile.save!
  puts "Created driver profile for #{driver.email}"
end

# Grant consents for driver
[ :terms_of_service, :location_tracking, :payment_processing ].each do |purpose|
  unless Consent.user_has_consent?(driver.id, purpose)
    Consent.grant_consent(
      user: driver,
      purpose: purpose,
      ip_address: "127.0.0.1",
      user_agent: "Seeds Script"
    )
    puts "Granted #{purpose} consent for #{driver.email}"
  end
end

puts "Database seeded successfully!"
