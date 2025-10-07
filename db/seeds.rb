# Seed file for church needs app
puts "Seeding database..."

# Create Oikos Community Church
puts "Creating Oikos Community Church..."
church = Church.find_or_create_by!(name: 'Oikos Community Church') do |c|
  c.address = '1199 Alton Road'
  c.city = 'Galloway'
  c.state = 'OH'
  c.zip = '43119'
  c.phone = ''
  c.email = ''
  c.timezone = 'America/New_York'
  c.active = true
end

# Create church admins
puts "Creating church admins..."
adam = church.users.find_or_create_by!(email_address: 'adam@bateswebdesign.com') do |user|
  user.password = ''
  user.name = 'Adam'
  user.phone = ''
  user.role = :admin
  user.is_church_admin = true
  user.email_verified = true
  user.active = true
end

tad = church.users.find_or_create_by!(email_address: 'ri@tadlamb.com') do |user|
  user.password = ''
  user.name = 'Tad'
  user.phone = ''
  user.role = :admin
  user.is_church_admin = false
  user.email_verified = true
  user.active = true
end

# Create sample members
puts "Creating sample members..."
member1 = church.users.find_or_create_by!(email_address: 'rachel@tadlamb.com') do |user|
  user.password = ''
  user.name = 'Rachel'
  user.phone = ''
  user.role = :member
  user.email_verified = true
  user.active = true
end

# Create default categories for the church
puts "Creating categories..."
Category.default_categories.each_with_index do |cat_data, index|
  church.categories.find_or_create_by!(name: cat_data[:name]) do |category|
    category.icon = cat_data[:icon]
    category.color = cat_data[:color]
    category.member_can_create = cat_data[:member_can_create]
    category.display_order = index
    category.active = true
  end
end

# Create sample checklist
puts "Creating sample checklists..."
cleaning_checklist = church.checklists.find_or_create_by!(name: 'Church Cleaning Checklist', created_by: adam) do |checklist|
  checklist.description = 'Standard cleaning tasks for church facilities'
  checklist.active = true
end

unless cleaning_checklist.checklist_items.any?
  [ 'Vacuum all carpets', 'Dust pews', 'Clean restrooms', 'Empty trash', 'Mop floors' ].each_with_index do |task, index|
    cleaning_checklist.checklist_items.create!(description: task, display_order: index)
  end
end

# Create sample needs
puts "Creating sample needs..."
cleaning_cat = church.categories.find_by(name: 'Cleaning')
meals_cat = church.categories.find_by(name: 'Meals')

if cleaning_cat
  church.needs.find_or_create_by!(title: 'Weekly Church Cleaning', creator: adam, category: cleaning_cat) do |need|
    need.description = 'Help keep our church clean and welcoming for Sunday service.'
    need.status = :published
    need.start_date = Date.today + 7.days
    need.end_date = Date.today + 7.days
    need.time_slot = :morning
    need.location = 'Church Main Building'
    need.volunteer_capacity = 3
    need.checklist = cleaning_checklist
  end
end

if meals_cat
  church.needs.find_or_create_by!(title: 'Meal Train for the Johnson Family', creator: tad, category: meals_cat) do |need|
    need.description = 'The Johnson family just welcomed a new baby! Sign up to provide a meal on any available day.'
    need.status = :published
    need.start_date = Date.today + 3.days
    need.end_date = Date.today + 17.days
    need.time_slot = :evening
    need.location = '123 Main St'
    need.volunteer_capacity = 1
    need.allow_individual_day_signup = true
  end
end

puts "Seed data created successfully!"
