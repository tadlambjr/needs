namespace :categories do
  desc "Add event categories to all existing churches"
  task add_event_categories: :environment do
    event_categories = [
      { name: 'Event', icon: 'calendar', color: '#F59E0B', member_can_create: false, category_type: :event },
      { name: 'Class', icon: 'book-open', color: '#8B5CF6', member_can_create: false, category_type: :event },
      { name: 'Meeting', icon: 'users', color: '#06B6D4', member_can_create: false, category_type: :event }
    ]
    
    Church.find_each do |church|
      event_categories.each_with_index do |cat_attrs, index|
        # Check if category already exists
        next if church.categories.exists?(name: cat_attrs[:name], category_type: :event)
        
        # Create the category with appropriate display_order
        max_order = church.categories.maximum(:display_order) || 0
        church.categories.create!(
          cat_attrs.merge(display_order: max_order + index + 1)
        )
        puts "Added #{cat_attrs[:name]} category to #{church.name}"
      end
    end
    
    puts "Event categories added to all churches"
  end
end
