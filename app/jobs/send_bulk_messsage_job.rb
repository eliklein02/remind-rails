class SendBulkMesssageJob < ApplicationJob
  queue_as :default

  def perform(*args)
    pn_array, message, current_organization = args
    return if current_organization.messages_blocked
    message = send_bulk_sms(pn_array, message, current_organization)
  end

  def send_bulk_sms(pn_array, what, current_organization)
    return if pn_array.empty?
    failed = []
    successes = []
    body = {
      "messages":
        pn_array.map do |pn|
          return if Contact.find_by(phone: pn).opted_out?
          {
            "from": current_organization.textgrid_phone_number,
            "to": pn,
            "body": what
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
    puts "Response code: #{response}"
    if response.code == 200
      response.each do |r|
        if r["status"] == "failed"
          if r["error_message"] == "'To' number invalid"
            c = Contact.find_by(phone: r["to"])
            c.destroy
          end
          failed << r["to"]
        else
          successes << r["to"]
        end
      end
      message = ""
      if failed.any?
        if successes.any?
         message =  "Sent successfully, but failed to send messages to: #{failed.join(', ')}"
        else
          message = "Failed to send messages to all numbers"
        end
      else
        message =  "All messages sent successfully"
      end
    else
      message = "Failed to send messages: #{response.code} - #{response.message}"
    end
    message
  end
end
