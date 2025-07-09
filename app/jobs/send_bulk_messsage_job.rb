class SendBulkMesssageJob < ApplicationJob
  queue_as :default

  def perform(*args)
    pn_array, message, current_organization = args
    return if current_organization.messages_blocked
    pn_array = Contact.where(phone: pn_array).where.not(opted_in_status: 2).pluck(:phone).uniq
    pn_array << current_organization.admin_phone_number if current_organization.admin_phone_number.present?
    return "No phone numbers provided." if pn_array.empty?
    job_id = self.job_id.to_s
    message = send_bulk_sms(pn_array, message, current_organization, job_id)
    ActionCable.server.broadcast("notification_channel_#{current_organization.id}", { message: message })
  end

  def send_bulk_sms(pn_array, what, current_organization, job_id)
    failed = []
    successes = []

    body = {
      "messages":
        pn_array.map do |pn|
          {
            "from": current_organization.textgrid_phone_number,
            "to": pn,
            "body": "#{current_organization.name == "Torah Vodaas" ? "Bais Chaim Yisroel" : current_organization.name}:\n#{what}"
          }
        end.compact
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
    rescue => e
      # Event.create(
      #     is_failure: true,
      #     message: e.message,
      #     should_notify_admin: false
      #   )
      puts "Error during HTTParty.post: #{e.message}"
    end
    if response.success?
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
    JobResult.create(job_id: job_id, message: message, organization_id: current_organization.id, failed_to_send_to: failed.join(", "), sent_to: successes.join(", "), original_message: what)
    message
  end
end
