class MessageHandler
  def self.init(params)
    case params[:receipients]
    when "all"
      status = [ send_message_all(params[:message]) ]
    when "individual"
      status = handle_specific(params[:contact_ids], params[:message])
    when "contact_affiliation"
      status = handle_contact_affiliation(params[:contact_id], params[:message])
    when "year_enrolled"
      status = handle_year_enrolled(params)
    end
    status
  end

  def self.send_sms(to, what, index)
    if to.opted_in?
      puts "sending sms #{what} to #{to.name}"
      job = SendMessageJob.set(wait: (index + 1) * 2.seconds).perform_later(to, what)
      MessageSent.create
      :sent
    else
      :was_opted_out
    end
  end

  def self.send_message_all(message)
    statuses = Contact.all.each_with_index.map do |c, index|
      puts c
      puts index
      return if index == 10
      if send_sms(c, message, index) == :sent
        :sent
      end
    end
    statuses.include?(:sent) ? :sent : :was_opted_out
  end

  def self.handle_specific(contact_ids, message)
    status = contact_ids.each_with_index.map do |c, index|
      contact = Contact.find(c)
      send_sms(contact, message, index)
    end
    status
  end

  def self.handle_contact_affiliation(contact_id, message)
    contact = Contact.find(contact_id)
    year_entered = contact.year_entered.to_s.to_time.to_i
    year_left = contact.year_left.to_s.to_time.to_i
    send_list = Contact.all.select do |c|
      (c.year_entered && c.year_left) && (year_entered <= c.year_left.to_s.to_time.to_i && year_left >= c.year_entered.to_s.to_time.to_i)
    end

    status = send_list.each_with_index.map do |c, index|
      send_sms(c, message, index)
    end
    status
  end

  def self.handle_year_enrolled(params)
    start_date = Date.strptime(params[:start], "%m/%d/%Y").to_s.to_time.to_i
    end_date = Date.strptime(params[:end], "%m/%d/%Y").to_s.to_time.to_i

    send_list = Contact.all.select do |c|
      (c.year_entered && c.year_left) && (start_date <= c.year_left.to_s.to_time.to_i && end_date >= c.year_entered.to_s.to_time.to_i)
    end
    status = send_list.each_with_index.map do |c, index|
      send_sms(c, params[:message], index)
    end
    status
  end
end
