class SendMessageJob < ApplicationJob
  queue_as :default


  def send_sms(to, what)
    response = HTTParty.post(
      URI("https://api.twilio.com/2010-04-01/Accounts/#{ENV.fetch("TWILIO_ACCOUNT_SID")}/Messages.json"),
      body: {
        "To" => to.phone,
        "From" => ENV.fetch("TWILIO_PHONE_NUMBER"),
        "Body" => what
      },
      basic_auth: {
        username: ENV.fetch("TWILIO_ACCOUNT_SID"),
        password: ENV.fetch("TWILIO_AUTH_TOKEN")
      },
    )
    response.inspect
  end
  def perform(*args)
    puts "sending message in the job"
  end
end
