class UserImportService
  attr_reader :church, :results

  def initialize(church)
    @church = church
    @results = { created: [], failed: [] }
  end

  def import_from_csv(file_path)
    require 'csv'
    
    CSV.foreach(file_path, headers: true, header_converters: :symbol) do |row|
      # Skip empty rows
      next if row[:name].blank? && row[:email].blank?
      
      create_user_from_row(row)
    end
    
    results
  rescue CSV::MalformedCSVError => e
    @results[:failed] << {
      name: "CSV Error",
      email: "",
      errors: "Invalid CSV format: #{e.message}"
    }
    results
  end

  def send_welcome_emails
    results[:created].each do |user|
      PasswordsMailer.welcome_new_user(user).deliver_later
    end
  end

  private

  def create_user_from_row(row)
    # Generate a secure random password
    temp_password = SecureRandom.alphanumeric(16)
    
    user = church.users.new(
      name: row[:name]&.strip,
      email_address: row[:email]&.strip,
      password: temp_password,
      password_confirmation: temp_password,
      role: :member,
      active: true,
      email_verified: false
    )
    
    if user.save
      @results[:created] << user
    else
      @results[:failed] << {
        name: row[:name],
        email: row[:email],
        errors: user.errors.full_messages.join(", ")
      }
    end
  end
end
