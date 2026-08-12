org = Organisation.find_or_create_by!(name: "Counterpoint Community Org") do |o|
  o.contact_email = "eo@counterpoint.example.org"
  o.default_auto_close_hours = 4
  o.timezone = "Australia/Sydney"
end

front_desk = Location.find_or_create_by!(organisation: org, slug: "front-desk") do |l|
  l.name = "Front Desk"
  l.programs = [ "Op Shop", "Food Relief", "Youth Program" ]
end

warehouse = Location.find_or_create_by!(organisation: org, slug: "warehouse") do |l|
  l.name = "Warehouse"
  l.programs = []
end

[ "Alex Nguyen", "Priya Patel", "Sam Taylor", "Jordan Lee", "Chris Wallace" ].each do |name|
  Person.find_or_create_by!(organisation: org, full_name: name)
end

puts "Seeded organisation: #{org.name}"
puts "Locations: #{org.locations.pluck(:name, :slug).inspect}"
puts "Sign-in page: http://localhost:3000/in/#{front_desk.slug}"
puts "Register:     http://localhost:3000/register"
