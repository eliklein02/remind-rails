class SetCarrierJob < ApplicationJob
  queue_as :default

  def perform(*args)
    user = Contact.find(args[0])
    phone = args[1].last(10)
    puts user
    puts phone
    response = HTTParty.get("https://api.numlookupapi.com/v1/validate/#{phone}?apikey=num_live_WaHKiCdCr36O6D8MkbhBEtLFqhjfpqCXfCJVhwPH&country_code=US")
    begin
      carrier =  response["carrier"]
    rescue => e
      puts e
    end
    if !carrier || carrier == ""
      carrier = "no carrier found"
    end
    user.update!(carrier: carrier)
  end
end
