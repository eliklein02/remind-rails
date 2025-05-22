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
      require "csv"
      file = params[:file]
      status = []
      skipped_missing_data = []
      date_formats = {
        "w": "11",
        "e": "9",
        "s": "4"
      }
      if current_organization.school?
        CSV.foreach(file, headers: true) do |row|
          h = row.to_hash
          # puts h
          h = h.transform_keys { |k| k == "year_came" ? "year_entered" : k }
          h = h.transform_keys { |k| k == "Name" ? "name" : k }
          h = h.transform_keys { |k| k == "Came" ? "year_entered" : k }
          h = h.transform_keys { |k| k == "Left" ? "year_left" : k }
          h = h.transform_keys { |k| k == "Email" ? "email" : k }
          h = h.transform_keys { |k| k == "Phone" ? "phone" : k }
          h = h.transform_keys { |k| k == "First Name" ? "first_name" : k }
          h = h.transform_keys { |k| k == "Last Name" ? "last_name" : k }
          h = h.transform_keys { |k| k == "Last" ? "last_name" : k }
          h = h.transform_keys { |k| k == "First" ? "first_name" : k }
          h = h.transform_keys { |k| k == "First name" ? "first_name" : k }
          h = h.transform_keys { |k| k == "Last name" ? "first_name" : k }
          h = h.transform_keys { |k| k == "Phone Number" ? "phone" : k }

          if h["first_name"]
            h["name"] = h["first_name"]
          end

          if h["first_name"] && h["last_name"]
            h["name"] = "#{h["first_name"]} #{h["last_name"]}"
          end

          # just making it lowercase
          h["year_left"] = h["year_left"].downcase if h["year_left"] != "" && h["year_left"] != nil
          h["year_entered"] = h["year_entered"].downcase if h["year_entered"] != "" && h["year_entered"] != nil

          # formatting the year_left from w24 or s19 to 1/11/2024 or 1/4/2019
          if h["year_left"] && date_formats.keys.map(&:to_s).any? { |k| h["year_left"].include?(k) }
            given_year_left_month = h["year_left"].split("")[0]
            given_year_left_year = h["year_left"].split("")[1..-1]
            month = date_formats[given_year_left_month.to_sym]
            year = "20#{given_year_left_year.join}"
            full_date = "1/#{month}/#{year}"
            h["year_left"] = Chronic.parse(full_date)
          end

          # formatting the year_entered from w24 or s19 to 1/11/2024 or 1/4/2019
          if h["year_entered"] && date_formats.keys.map(&:to_s).any? { |k| h["year_entered"].include?(k) }
            given_year_entered_month = h["year_entered"].split("")[0]
            given_year_entered_year = h["year_entered"].split("")[1..-1]
            month = date_formats[given_year_entered_month.to_sym]
            year = "20#{given_year_entered_year.join}"
            full_date = "1/#{month}/#{year}"
            h["year_entered"] = Chronic.parse(full_date)
          end

          contact_attributes = Contact.attribute_names

          if h.key?("name") && h["name"] != nil && h["name"] != "" && h.key?("phone") && h["phone"] != nil && h["phone"] != ""
            h = h.slice(*contact_attributes)
            contact = Contact.find_or_initialize_by(h)
            if contact.save
              status << "saved"
            else
              status << "not saved"
            end
          else
            skipped_missing_data << h
          end
        end

      elsif current_organization.shul?
        CSV.foreach(file, headers: true) do |row|
          h = row.to_hash.transform_keys { |k| k == "Name" ? "name" : k }
          h = row.to_hash.transform_keys { |k| k == "Phone" ? "phone" : k }
          h = row.to_hash.transform_keys { |k| k == "Email" ? "email" : k }
          if h.key?("name") && h["name"] != nil && h["name"] != "" && h.key?("phone") && h["phone"] != nil && h["phone"] != ""
            c = Contact.find_or_initialize_by(h)
            if c.save
              status << "saved"
            else
              status << "not saved"
            end
          else
            status << "missing data"
            skipped_missing_data << h
          end
        end
      end
      if !status.include?("saved")
        flash[:alert] = "Something went wrong. Please make sure the fields are all correct."
        redirect_to "/contacts/import"
      else
        if status.include?("missing data")
          flash[:warning] = "Contacts were successfully saved, but some were skipped due to incomplete data. Please review the file to confirm."
        else
          flash[:notice] = "Contacts were successfully saved."
        end
        redirect_to contacts_path
      end
    rescue => e
      puts "error reading file: #{e}"
      flash[:alert] = "Something went wrong. Please make sure the file is in the correct format."
      redirect_to "/contacts/import"
    end
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
