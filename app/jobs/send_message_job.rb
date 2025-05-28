class SendMessageJob < ApplicationJob
  queue_as :default

  def send_sms(to, what, current_organization)
    response = HTTParty.post(
      URI("#{ENV.fetch("BASE_TEXTGRID_URL")}/Accounts/#{current_organization.textgrid_account_sid}/Messages.json"),
      body: {
        "to" => to.phone,
        "from" => current_organization.textgrid_phone_number,
        "body" => what
      }.to_json,
      headers: {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{current_organization.encoded_textgrid_credentials}"
      },
    )
    response
  end
  def perform(*args)
    return if current_organization.messages_blocked
    response = send_sms(args[0], args[1], args[2])
    response.code
  end
end
