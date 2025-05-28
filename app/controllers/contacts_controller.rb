class ContactsController < ApplicationController
  before_action :set_contact, only: [ :show, :edit, :update, :destroy ]

  def index
    @contacts = Contact.all.sort_by { |c| c.name.to_s }
  end

  def show
  end

  def new
    @contact = Contact.new
  end

  def create
    puts params
    @contact = Contact.find_or_initialize_by(name: contact_params[:name], phone: contact_params[:phone])
    @contact.email = contact_params[:email] if contact_params[:email].present?
    @contact.year_entered = contact_params[:year_entered] if contact_params[:year_entered].present?
    @contact.year_left = contact_params[:year_left] if contact_params[:year_left].present?
    if @contact.save
      flash[:notice] = "Contact was successfully created."
      redirect_to @contact
    else
      render :new
    end
  end

  def edit
  end

  def update
    puts contact_params
    if @contact.update(contact_params)
      flash[:notice] = "Contact was successfully updated."
      redirect_to @contact
    else
      render :edit
    end
  end

  def destroy
    @contact.destroy
    flash[:notice] = "Contact was successfully deleted."
    redirect_to contacts_path
  end

  def send_message
    return if params[:message] == ""
    if params[:receipients] == "contact_affiliation"
      if Contact.find(params[:contact_id]).name != params[:contact_name]
        redirect_back_or_to root_path
      end
    end
    puts MessageHandler.init(params, current_organization)
    redirect_back_or_to root_path
  end

  def import_contacts
  end

  def import
    begin
      file = params[:file]
      table = CSV.read(file, headers: false)
      season_name = table[0][0].split(" ")[-2..-1].join(" ")
      s = Season.find_or_create_by(name: season_name)
      table = table.drop(1)
      csv_string = table.map(&:to_csv).join
      CSV.parse(csv_string, headers: true) do |r|
        h = r.to_hash
        if h["First Name"] && h["Last Name"]
          h["name"] = "#{h["First Name"]} #{h["Last Name"]}"
        elsif h["first name"] && h["last name"]
          h["name"] = "#{h["first name"]} #{h["last name"]}"
        elsif h["first name"]
          h["name"] = h["first name"]
        elsif h["last name"]
          h["name"] = h["last name"]
        elsif h["First Name"]
          h["name"] = h["First Name"]
        elsif h["Last Name"]
          h["name"] = h["Last Name"]
        else
          next
        end
        h = h.transform_keys { |k| !k.nil? && k.include?("cell") || !k.nil? && k.include?("Cell") ? "phone" : k }
        h = h.transform_keys { |k| k == "Phone" ? "phone" : k }
        h = h.transform_keys { |k| k == "Email" ? "email" : k }

        if h["phone"].blank?
          puts "Skipping row due to missing phone number: #{h}"
          next
        end
        phone = to_e164(h["phone"])
        contact = current_organization.contacts.find_or_initialize_by(name: h["name"])
        contact.phone = phone
        contact.email = h["email"] if h["email"].present? && h["email"] != ""
        if contact.save
          contact.seasons << s unless contact.seasons.include?(s)
        else
          puts "failed: #{contact.errors.full_messages}"
          puts h
        end
      end
    rescue => e
      flash[:alert] = "There was an error importing the file. Please check the file format and try again."
      puts "Error parsing CSV: #{e.inspect}"
      redirect_to "/contacts/import"
    end
  end

  def to_e164(p)
    phone = p
    phone.gsub!(/[^0-9]/, "")
    phone = "+1#{phone[0..2]}#{phone[3..5]}#{phone[6..9]}" if phone.length === 10
    phone = "+1#{phone[1..3]}#{phone[4..6]}#{phone[7..10]}" if phone.length === 11
    phone
  end

  private

  def set_contact
    @contact = Contact.find(params[:id])
  end

  def contact_params
    params.require(:contact).permit(:name, :email, :phone, :year_entered, :year_left).tap do |c_p|
      c_p[:year_entered] = Date.parse(Chronic.parse(c_p[:year_entered]).to_s) if c_p[:year_entered].present?
      c_p[:year_left] =  Date.parse(Chronic.parse(c_p[:year_left]).to_s) if c_p[:year_left].present?
    end
  end
end
