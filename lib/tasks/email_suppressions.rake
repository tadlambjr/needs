namespace :email do
  desc "Sync email suppressions with Postmark"
  task sync_suppressions: :environment do
    require 'postmark'
    
    api_token = ENV['POSTMARK_API_TOKEN']
    unless api_token
      puts "Error: POSTMARK_API_TOKEN not set"
      exit 1
    end
    
    client = Postmark::ApiClient.new(api_token)
    
    begin
      # Fetch suppression list from Postmark
      puts "Fetching suppression list from Postmark..."
      
      # Get bounces
      bounces = client.get_bounces(count: 500)
      puts "Found #{bounces[:total_count]} bounces"
      
      bounces[:bounces].each do |bounce|
        email = bounce[:email]
        user = User.find_by(email_address: email)
        
        next unless user
        
        case bounce[:type]
        when "HardBounce"
          unless user.email_suppressed?
            user.record_bounce!(type: :hard_bounce)
            puts "  Suppressed #{email} (hard bounce)"
          end
        when "SpamComplaint"
          unless user.email_suppressed?
            user.record_spam_complaint!
            puts "  Suppressed #{email} (spam complaint)"
          end
        end
      end
      
      puts "Sync complete!"
      puts "Total suppressed users: #{User.where(email_suppressed: true).count}"
      
    rescue Postmark::ApiInputError => e
      puts "Postmark API error: #{e.message}"
      exit 1
    rescue StandardError => e
      puts "Error: #{e.message}"
      puts e.backtrace.join("\n")
      exit 1
    end
  end
  
  desc "List all suppressed email addresses"
  task list_suppressed: :environment do
    suppressed = User.where(email_suppressed: true)
    
    if suppressed.empty?
      puts "No suppressed email addresses found."
    else
      puts "Suppressed email addresses (#{suppressed.count}):"
      puts "-" * 80
      
      suppressed.find_each do |user|
        reason = if user.email_complaint_at.present?
          "Spam complaint (#{user.email_complaint_at.to_date})"
        elsif user.hard_bounce?
          "Hard bounce (#{user.email_bounced_at.to_date})"
        elsif user.soft_bounce?
          "Soft bounces (#{user.bounce_count}x, last: #{user.email_bounced_at.to_date})"
        else
          "Unknown"
        end
        
        puts "#{user.email_address.ljust(40)} | #{reason}"
      end
    end
  end
  
  desc "Unsuppress an email address"
  task :unsuppress, [:email] => :environment do |t, args|
    unless args[:email]
      puts "Usage: rake email:unsuppress[user@example.com]"
      exit 1
    end
    
    user = User.find_by(email_address: args[:email])
    
    unless user
      puts "Error: User with email #{args[:email]} not found"
      exit 1
    end
    
    if user.email_suppressed?
      user.unsuppress_email!
      puts "✓ Email unsuppressed for #{args[:email]}"
    else
      puts "Email #{args[:email]} is not suppressed"
    end
  end
  
  desc "Clean up old soft bounces (reset after 30 days)"
  task cleanup_soft_bounces: :environment do
    cutoff_date = 30.days.ago
    
    users = User.where(email_bounce_status: :soft_bounce)
                .where("email_bounced_at < ?", cutoff_date)
                .where(email_suppressed: false)
    
    count = users.count
    
    if count.zero?
      puts "No old soft bounces to clean up."
    else
      users.update_all(
        email_bounce_status: 0, # no_bounce
        bounce_count: 0
      )
      puts "✓ Cleaned up #{count} old soft bounce records"
    end
  end
  
  desc "Report on email deliverability stats"
  task stats: :environment do
    total_users = User.count
    active_users = User.active.count
    suppressed = User.where(email_suppressed: true).count
    hard_bounces = User.hard_bounce.count
    soft_bounces = User.soft_bounce.count
    spam_complaints = User.where.not(email_complaint_at: nil).count
    emailable = User.emailable.count
    
    puts "Email Deliverability Statistics"
    puts "=" * 80
    puts "Total users:              #{total_users}"
    puts "Active users:             #{active_users}"
    puts "Emailable users:          #{emailable}"
    puts ""
    puts "Suppressed:               #{suppressed} (#{percentage(suppressed, total_users)}%)"
    puts "  - Hard bounces:         #{hard_bounces}"
    puts "  - Soft bounces:         #{soft_bounces}"
    puts "  - Spam complaints:      #{spam_complaints}"
    puts ""
    
    recent_bounces = User.where("email_bounced_at > ?", 7.days.ago).count
    puts "Bounces (last 7 days):    #{recent_bounces}"
    
    recent_complaints = User.where("email_complaint_at > ?", 7.days.ago).count
    puts "Spam complaints (7d):     #{recent_complaints}"
  end
  
  private
  
  def percentage(part, whole)
    return 0 if whole.zero?
    ((part.to_f / whole) * 100).round(2)
  end
end
