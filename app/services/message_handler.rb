class MessageHandler
  def self.init(params)
    case params[:receipients]
    when "all"
      status = [ send_message_all(params[:message]) ]
    when "individual"
      status = params[:contact_ids].each.map do |c|
        contact = Contact.find(c)
        send_message_specific(contact, params[:message])
      end
    when "contact_affiliation"
      status = handle_contact_affiliation(params[:contact_id], params[:message])
    when "year_enrolled"
      status = handle_year_enrolled(params)
    end
    status
  end

  def self.send_sms(to, what)
    if to.opted_in?
      puts "sending sms #{what} to #{to.name}"
      :sent
    else
      :was_opted_out
    end
  end

  def self.send_message_all(message)
    Contact.all.each do |c|
      if send_sms(c, message) == :sent
        return :sent
      else
        return :was_opted_out
      end
    end
  end

  def self.send_message_specific(to, message)
    send_sms(to, message)
  end

  def self.handle_contact_affiliation(contact_id, message)
    contact = Contact.find(contact_id)
    year_entered = contact.year_entered.to_s.to_time.to_i
    year_left = contact.year_left.to_s.to_time.to_i
    send_list = Contact.all.select do |c|
      (c.year_entered && c.year_left) && (year_entered <= c.year_left.to_s.to_time.to_i && year_left >= c.year_entered.to_s.to_time.to_i)
    end

    status = send_list.each.map do |c|
      send_sms(c, message)
    end
    status
  end

  def self.handle_year_enrolled(params)
    start_date = Date.strptime(params[:start], "%m/%d/%Y").to_s.to_time.to_i
    end_date = Date.strptime(params[:start], "%m/%d/%Y").to_s.to_time.to_i

    send_list = Contact.all.select do |c|
      puts c.year_entered.to_s.to_time.to_i
      (c.year_entered && c.year_left) && (start_date <= c.year_left.to_s.to_time.to_i && end_date >= c.year_entered.to_s.to_time.to_i)
    end
    status = send_list.each.map do |c|
      send_sms(c, params[:message])
    end
    status
  end
end
