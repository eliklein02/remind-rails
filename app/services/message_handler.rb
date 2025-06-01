class MessageHandler
  def self.init(params, current_organization)
    case params[:receipients]
    when "all"
      status = [ send_message_all(params[:message], current_organization) ]
    when "individual"
      status = handle_specific(params[:contact_ids], params[:message], current_organization)
    when "contact_affiliation"
      if params[:contact_ids].present?
        status = handle_contact_affiliation(params[:contact_id], params[:message], current_organization, params[:contact_ids])
      else
        status = handle_contact_affiliation(params[:contact_id], params[:message], current_organization)
      end
      # when "year_enrolled"
      #   status = handle_year_enrolled(params, current_organization)
    end
    status
  end

  # Sends a message to all contacts in the organization
  def self.send_message_all(message, current_organization)
    send_list = Contact.all.map(&:phone)
    send_bulk_sms(send_list, message, current_organization)
  end

  # Sends a message to specific contacts by their IDs which are passed in as an array
  def self.handle_specific(contact_ids, message, current_organization)
    status = contact_ids.map do |c|
      contact = Contact.find(c)
      send_sms(contact, message, current_organization)
    end
    status
  end

  # Handles sending messages to contacts affiliated with a specific contact based on their seasons
  def self.handle_contact_affiliation(contact_id, message, current_organization, contact_ids_array = [])
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
    puts send_list
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
  def self.send_sms(to, what, index, current_organization)
    job = SendMessageJob.set.perform_later(to, what, current_organization)
  end

  # Sends a bulk SMS to an array of phone numbers and logs the message sent
  def self.send_bulk_sms(to_array, what, current_organization)
    job = SendBulkMesssageJob.perform_later(to_array, what, current_organization)
  end
end
