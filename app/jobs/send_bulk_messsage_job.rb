class SendBulkMesssageJob < ApplicationJob
  queue_as :default

  def perform(*args)
    pn_array, message, current_organization = args
    return if current_organization.messages_blocked
    message = send_bulk_sms(pn_array, message, current_organization)
    job_id = self.job_id.to_s
    puts "Creating JobResult with job_id: #{job_id}"
    # jr = JobResult.create(job_id: job_id, message: message)
    ActionCable.server.broadcast("notification_channel_#{current_organization.id}", { message: message })
    # puts "Saved JobResult: #{jr.inspect}"
  end

  def send_bulk_sms(pn_array, what, current_organization)
    return if pn_array.empty?
    failed = []
    successes = []
    body = {
      "messages":
        pn_array.map do |pn|
          next if Contact.find_by(phone: pn).opted_out?
          {
            "from": current_organization.textgrid_phone_number,
            "to": pn,
            "body": "#{current_organization.name == "Torah Vodaas" ? "Bais Chaim Yisroel" : current_organization.name}:\n#{what}"
          }
        end
    }.to_json
    headers = {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{current_organization.encoded_textgrid_credentials}"
    }
    url = URI("#{ENV.fetch("BASE_TEXTGRID_URL")}/Accounts/#{current_organization.textgrid_account_sid}/BulkMessages.json")
    begin
      response = HTTParty.post(url,
        body: body,
        headers: headers
      )
    rescue StandardError => e
      puts "Error during HTTParty.post: #{e.message}"
    end
    if response.code == 200
      response.each do |r|
        if r["status"] == "failed"
          failed << Contact.find_by(phone: r["to"]).name
        else
          successes << r["to"]
          MessageSent.create!(
            body: r["body"],
            contact_id: Contact.find_by(phone: r["to"]).id
          )
        end
      end
      message = ""
      if failed.any?
        if successes.any?
         message =  "Sent successfully, but failed to send messages to:\n #{failed.join(', ')}\n please check their phone numbers."
        else
          message = "Failed to send messages to all contacts. Please try again."
        end
      else
        message =  "Messages sent successfully"
      end
    else
      message = "Failed to send messages: #{response.code} - #{response.message}"
    end
    message
  end
end
