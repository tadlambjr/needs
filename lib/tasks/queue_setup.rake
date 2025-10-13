namespace :queue do
  desc "Setup queue database schema"
  task setup_schema: :environment do
    # Get the queue database configuration
    queue_config = ActiveRecord::Base.configurations.configs_for(env_name: Rails.env, name: "queue")
    
    if queue_config
      # Establish connection to queue database
      ActiveRecord::Base.establish_connection(queue_config)
      
      # Load the queue schema
      load Rails.root.join("db/queue_schema.rb")
      
      puts "Queue database schema loaded successfully!"
      
      # Reconnect to primary database
      ActiveRecord::Base.establish_connection(:primary)
    else
      puts "Queue database configuration not found!"
    end
  end
end
