class MessageHandler
  def self.init(params)
    case params[:receipients]
    when "all"
      send_message_all(params[:message])
    when "individual"
      params[:contact_ids].each do |c|
        contact = Contact.find(c)
        send_message_specific(contact, params[:message])
      end
    when "contact_affiliation"
      handle_contact_affiliation(params[:contact_id], params[:message])
    when "year_enrolled"
      handle_year_enrolled(params)
    end
  end

  def self.send_sms(to, what)
    if to.opted_in?
      puts "sending sms #{what} to #{to.name}"
    else
      :was_opted_out
    end
  end

  def self.send_message_all(message)
    Contact.all.each do |c|
        puts send_sms(c, message)
    end
  end

  def self.send_message_specific(to, message)
    puts send_sms(to, message)
  end

  def self.handle_contact_affiliation(contact_id, message)
    contact = Contact.find(contact_id)
    year_entered = contact.year_entered.to_s.to_time.to_i
    year_left = contact.year_left.to_s.to_time.to_i
    send_list = Contact.all.select do |c|
      (c.year_entered && c.year_left) && (year_entered <= c.year_left.to_s.to_time.to_i && year_left >= c.year_entered.to_s.to_time.to_i)
    end

    send_list.each do |c|
      send_sms(c, message)
    end
  end

  def self.handle_year_enrolled(params)
    start_date = Date.strptime(params[:start], "%m/%d/%Y").to_s.to_time.to_i
    end_date = Date.strptime(params[:start], "%m/%d/%Y").to_s.to_time.to_i

    send_list = Contact.all.select do |c|
      puts c.year_entered.to_s.to_time.to_i
      (c.year_entered && c.year_left) && (start_date <= c.year_left.to_s.to_time.to_i && end_date >= c.year_entered.to_s.to_time.to_i)
    end
    send_list.each do |c|
      send_sms(c, params[:message])
    end
  end
end
