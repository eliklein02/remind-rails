class SendBulkMesssageJob < ApplicationJob
  queue_as :default

  def perform(*args)
    pn_array, message, current_organization = args
    send_bulk_sms(pn_array, message, current_organization)
  end

  def send_bulk_sms(pn_array, what, current_organization)
    body = {
      "messages":
        pn_array.map do |pn|
          {
            "from": current_organization.textgrid_phone_number,
            "to": pn,
            "body": what
          }
        end
    }.to_json
    puts body
    url =  URI("#{ENV.fetch("BASE_TEXTGRID_URL")}/Accounts/#{current_organization.textgrid_account_sid}/BulkMessages.json")
    response = HTTParty.post(url,
      body: body,
      headers: {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{current_organization.encoded_textgrid_credentials}"
      },
    )
    puts response
    response
  end
end
