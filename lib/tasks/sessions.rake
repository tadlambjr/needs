namespace :sessions do
  desc "Clean up expired restore tokens (older than 1 hour)"
  task cleanup_restore_tokens: :environment do
    # Remove restore tokens from sessions older than 1 hour
    count = Session.where.not(restore_token: nil)
                   .where("updated_at < ?", 1.hour.ago)
                   .update_all(restore_token: nil)
    
    puts "Cleaned up #{count} expired restore token(s)"
  end
  
  desc "Clean up old sessions (older than 30 days)"
  task cleanup_old_sessions: :environment do
    count = Session.where("updated_at < ?", 30.days.ago).delete_all
    puts "Deleted #{count} old session(s)"
  end
end
