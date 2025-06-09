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
    @contact = Contact.find_or_initialize_by(phone: to_e164(contact_params[:phone]))
    @contact.name = contact_params[:name] if contact_params[:name].present?
    @contact.email = contact_params[:email] if contact_params[:email].present?
    @contact.is_staff = contact_params[:is_staff] if contact_params[:is_staff].present?
    if @contact.persisted?
      flash[:alert] = "Contact already exists with that name and phone number."
      return redirect_to @contact
    end
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
    message = MessageHandler.init(params, current_organization)
    flash[:spinner] = message
    redirect_back_or_to root_path
  end

  def import_contacts
  end

  def import
    puts current_organization.inspect
    status = []
    skipped_missing_data = []
    file = params[:file]
    if current_organization.name == "Torah Vodaas"
      begin
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
          contact = Contact.find_or_initialize_by(name: h["name"])
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
    else
      begin
        CSV.foreach(file, headers: true) do |row|
          h = row.to_hash
          # puts h.inspect
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
          end
          h = h.transform_keys { |k| k == "Name" ? "name" : k }
          h = h.transform_keys { |k| k == "Phone" ? "phone" : k }
          h = h.transform_keys { |k| k == "Email" ? "email" : k }
          puts h.inspect
          if h.key?("name") && h["name"] != nil && h["name"] != "" && h.key?("phone") && h["phone"] != nil && h["phone"] != ""
            c = Contact.find_or_initialize_by(phone: to_e164(h["phone"]))
            c.name = h["name"]
            if c.save
              status << "saved"
            else
              status << "not saved"
            end
          else
            status << "missing data"
            skipped_missing_data << h
            puts "Skipping row due to missing name or phone number: #{h}"
          end
        end
      rescue => exception
          puts "Error parsing CSV: #{exception.inspect}"
          flash[:alert] = "There was an error importing the file. Please check the file format and try again."
          redirect_to "/contacts/import"
      end
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
    params.require(:contact).permit(:name, :email, :phone, :is_staff)
  end
end
