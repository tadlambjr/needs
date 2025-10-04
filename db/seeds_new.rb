# Seed file for church needs app
puts "Seeding database..."

# Create default categories
puts "Creating categories..."
Category.default_categories.each_with_index do |cat_data, index|
  Category.find_or_create_by!(name: cat_data[:name]) do |category|
    category.icon = cat_data[:icon]
    category.color = cat_data[:color]
    category.member_can_create = cat_data[:member_can_create]
    category.display_order = index
    category.active = true
  end
end

# Create admin user
puts "Creating admin user..."
admin = User.find_or_create_by!(email_address: 'admin@church.org') do |user|
  user.password = 'password123'
  user.name = 'Admin User'
  user.phone = '555-0100'
  user.role = :admin
  user.email_verified = true
  user.active = true
end

# Create sample members
puts "Creating sample members..."
member1 = User.find_or_create_by!(email_address: 'john@example.com') do |user|
  user.password = 'password123'
  user.name = 'John Smith'
  user.phone = '555-0101'
  user.role = :member
  user.email_verified = true
  user.active = true
end

member2 = User.find_or_create_by!(email_address: 'jane@example.com') do |user|
  user.password = 'password123'
  user.name = 'Jane Doe'
  user.phone = '555-0102'
  user.role = :member
  user.email_verified = true
  user.active = true
end

# Create sample checklist
puts "Creating sample checklists..."
cleaning_checklist = Checklist.find_or_create_by!(name: 'Church Cleaning Checklist', created_by: admin) do |checklist|
  checklist.description = 'Standard cleaning tasks for church facilities'
  checklist.active = true
end

unless cleaning_checklist.checklist_items.any?
  ['Vacuum all carpets', 'Dust pews', 'Clean restrooms', 'Empty trash', 'Mop floors'].each_with_index do |task, index|
    cleaning_checklist.checklist_items.create!(description: task, display_order: index)
  end
end

# Create sample needs
puts "Creating sample needs..."
cleaning_cat = Category.find_by(name: 'Cleaning')
meals_cat = Category.find_by(name: 'Meals')

if cleaning_cat
  Need.find_or_create_by!(title: 'Weekly Church Cleaning', creator: admin, category: cleaning_cat) do |need|
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
  Need.find_or_create_by!(title: 'Meal Train for the Johnson Family', creator: admin, category: meals_cat) do |need|
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
puts "Admin login: admin@church.org / password123"
puts "Member login: john@example.com / password123"
