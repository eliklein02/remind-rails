class MessageHandler
  def self.init(params, current_organization)
    case params[:receipients]
    when "all"
      message = send_message_all(params[:message], current_organization, params[:send_to_staff])
    when "individual"
      message = handle_specific(params[:contact_ids], params[:message], current_organization)
    when "contact_affiliation"
      if params[:contact_ids].present?
        message = handle_contact_affiliation(params[:contact_id], params[:message], current_organization, params[:contact_ids], params[:send_to_staff])
      else
        message = handle_contact_affiliation(params[:contact_id], params[:message], current_organization, params[:send_to_staff])
      end
      # when "year_enrolled"
      #   status = handle_year_enrolled(params, current_organization)
    end
    message
  end

  # Sends a message to all contacts in the organization
  def self.send_message_all(message, current_organization, send_to_staff)
    if send_to_staff == "1"
      send_list = Contact.all.pluck(:phone)
    else
      send_list = Contact.where.not(is_staff: true).pluck(:phone)
    end
    send_list << current_organization.admin_phone_number if current_organization.admin_phone_number.present?
    # puts send_list.inspect
    send_bulk_sms(send_list, message, current_organization)
  end

  # Sends a message to specific contacts by their IDs which are passed in as an array
  def self.handle_specific(contact_ids, message, current_organization)
    status = contact_ids.map do |c|
      contact = Contact.find(c)
      send_sms(contact, message, current_organization)
    end
    if !status.include?("Message Sent Successfully")
      message = "Message not sent: #{status[0]}"
    else
      succes, failed = status.partition { |s| s == "Message Sent Successfully" }
      if failed.any?
        message = "Message sent successfully to #{succes.count} contacts, but failed for: #{failed.count} #{failed.count == 1 ? "contact" : "contacts"}. Please check the phone numbers."
      else
        message = "Message sent successfully to all selected contacts."
      end
    end
  end

  # Handles sending messages to contacts affiliated with a specific contact based on their seasons
  def self.handle_contact_affiliation(contact_id, message, current_organization, contact_ids_array = nil, send_to_staff)
    contact_ids_array ||= []
    contact = Contact.find(contact_id)
    contact_seasons = contact.seasons
    puts contact_seasons
    send_list = Set.new
    if current_organization.name == "Torah Vodaas"
      contact_seasons.each do |c|
        c.contacts.each do |co|
          send_list << co.phone
        end
      end
    else
      send_list.merge(
        Contact.where.not(year_entered: nil, year_left: nil)
                .where("year_entered <= ? AND year_left >= ?", contact.year_left, contact.year_entered)
                .pluck(:phone)
      )
    end
    send_list.merge(
      Contact.where(id: contact_ids_array)
             .pluck(:phone)
    )
    send_list = send_list.to_a
    if send_to_staff == "1" || send_to_staff == 1
      Contact.staff.each do |c|
        send_list << c.phone
      end
    end
    send_list << current_organization.admin_phone_number if current_organization.admin_phone_number.present?
    send_bulk_sms(send_list, message, current_organization)
  end


  # def self.handle_year_enrolled(params, current_organization)
  #   start_date = Date.strptime(params[:start], "%m/%d/%Y").to_s.to_time.to_i
  #   end_date = Date.strptime(params[:end], "%m/%d/%Y").to_s.to_time.to_i

  #   send_list = Contact.all.select do |c|
  #     (c.year_entered && c.year_left) && (start_date <= c.year_left.to_s.to_time.to_i && end_date >= c.year_entered.to_s.to_time.to_i)
  #   end
  #   send_list = send_list.map(&:phone)
  #   puts send_list
  #   response = send_bulk_sms(send_list, params[:message], current_organization)
  # end

  # Sends an SMS to a single contact and logs the message sent
  def self.send_sms(to, what, current_organization)
    job = SendMessageJob.perform_later(to, what, current_organization)

    found = nil

    tries = 0

    while found.nil? && tries < 50
      sleep 1
      found = JobResult.find_by(job_id: job.job_id)
      tries = tries + 1
    end

    if !found.nil?
      tries = 0
      found.message
    else
      "Something went wrong."
    end
  end

  # Sends a bulk SMS to an array of phone numbers and logs the message sent
  def self.send_bulk_sms(to_array, what, current_organization)
    job = SendBulkMesssageJob.perform_later(to_array, what, current_organization)

    # found = nil

    # tries = 0

    # while found.nil? && tries < 25
    #   sleep 1
    #   found = JobResult.find_by(job_id: job.job_id)
    #   tries = tries + 1
    # end

    # if !found.nil?
    #   tries = 0
    #   found.message
    # else
    #   "Something went wrong."
    # end
    if job
      "Message Sent Successfully, awaiting results."
    else
      "Message not sent, please try again."
    end
  end
end
