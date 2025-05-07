class Contact < ApplicationRecord
  acts_as_tenant :organization

  after_create_commit -> { send_opt_in_message }

  enum :opted_in_status, [ :was_not_asked, :opted_in, :opted_out ]

  def send_opt_in_message
    puts "sending opt in message to #{self.name}"
  end
end
