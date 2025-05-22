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
    when "year_enrolled"
      status = handle_year_enrolled(params, current_organization)
    end
    status
  end

  def self.send_message_all(message, current_organization)
    send_list = Contact.all.map(&:phone)
    send_bulk_sms(send_list, message, current_organization)
  end

  def self.handle_specific(contact_ids, message, current_organization)
    status = contact_ids.each_with_index.map do |c, index|
      contact = Contact.find(c)
      send_sms(contact, message, index, current_organization)
    end
    status
  end

  def self.handle_contact_affiliation(contact_id, message, current_organization, contact_ids_array = [])
    contact = Contact.find(contact_id)
    send_list = Contact.all.select do |c|
      if current_organization.name == "Torah Vodaas"
        year_left = contact.year_left || Date.today
        (c.year_left) && (c.year_left < year_left + 2.years && c.year_left > year_left - 2.years)
      else
        year_entered = contact.year_entered.to_s.to_time.to_i
        year_left = contact.year_left.to_s.to_time.to_i
        (c.year_entered && c.year_left) && (year_entered <= c.year_left.to_s.to_time.to_i && year_left >= c.year_entered.to_s.to_time.to_i)
      end
    end
    contact_ids_array.each do |c|
      contact = Contact.find(c)
      send_list << contact
    end
    send_list = send_list.map(&:phone)
    send_bulk_sms(send_list, message, current_organization)
  end

  def self.handle_year_enrolled(params, current_organization)
    start_date = Date.strptime(params[:start], "%m/%d/%Y").to_s.to_time.to_i
    end_date = Date.strptime(params[:end], "%m/%d/%Y").to_s.to_time.to_i

    send_list = Contact.all.select do |c|
      (c.year_entered && c.year_left) && (start_date <= c.year_left.to_s.to_time.to_i && end_date >= c.year_entered.to_s.to_time.to_i)
    end
    send_list = send_list.map(&:phone)
    puts send_list
    response = send_bulk_sms(send_list, params[:message], current_organization)
  end

  def self.send_sms(to, what, index, current_organization)
    job = SendMessageJob.set(wait: (index + 1) * 2.seconds).perform_later(to, what, current_organization)
    MessageSent.create(contact_id: to.id, body: what)
    :sent
  end

  def self.send_bulk_sms(to_array, what, current_organization)
    job = SendBulkMesssageJob.perform_later(to_array, what, current_organization)
    job
  end
end
