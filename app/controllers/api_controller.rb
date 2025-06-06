class ApiController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_organization!
  def textgrid_webhook
    puts "Ho ho ho"
    organization = Organization.find_by(textgrid_phone_number: params["To"])
    puts organization.inspect
    ActsAsTenant.with_tenant(organization) do
      contact = Contact.find_by(phone: params["From"])
      message = params["Body"]
      unsubscribe_keywords = [ "opt out", "optout", "stop", "unsubscribe", "exit", "cancel", "#exit", "#stop" ]
      if message.to_s.downcase.strip.in?(unsubscribe_keywords)
        if contact
          contact.update(opted_in_status: 2)
          return head :ok
        else
          return head :ok
        end
      end
      puts "sending sms"
      send_sms(contact, message, organization)
    end
    head :ok
  end

  def send_sms(to, what, organization)
    url = URI("#{ENV.fetch("BASE_TEXTGRID_URL")}/Accounts/#{organization.textgrid_account_sid}/Messages.json")
    message_body = "#{to.name} said: #{what}"
    response = HTTParty.post(
      url,
      body: {
        "to" => organization.admin_phone_number,
        "from" => organization.textgrid_phone_number,
        "body" => message_body
      }.to_json,
      headers: {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{organization.encoded_textgrid_credentials}"
      },
    )
    if response.code != 200
      Rails.logger.error("Failed to send SMS: #{response.code} - #{response.message}")
    else
      Rails.logger.info("SMS sent successfully to #{to.name}: #{what}")
    end
    MessageSent.create!(
      body: message_body,
      contact_id: Contact.find_by(phone: organization.admin_phone_number).id || nil
    )
  end
end
