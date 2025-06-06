class SendMessageJob < ApplicationJob
  queue_as :default
  require "net/http"

  def send_sms(to, what, current_organization)
    url = URI("#{ENV.fetch("BASE_TEXTGRID_URL")}/Accounts/#{current_organization.textgrid_account_sid}/Messages.json")
    response = HTTParty.post(
      url,
      body: {
        "to" => to.phone,
        "from" => current_organization.textgrid_phone_number,
        "body" => "#{current_organization.name == "Torah Vodaas" ? "Bais Chaim Yisroel" : current_organization.name}:\n#{what}"
      }.to_json,
      headers: {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{current_organization.encoded_textgrid_credentials}"
      },
    )
    if response.code == 200
      message = "Message Sent Successfully"
      MessageSent.create(
        body: what,
        contact_id: to.id
      )
    else
      message = response["Message"]
    end
    message
  end
  def perform(*args)
    to, what, current_organization = args
    return if current_organization.messages_blocked
    return if to.opted_out?
    message = send_sms(to, what, current_organization)
    JobResult.create!(
      job_id: self.job_id,
      message: message
    )
  end
end
