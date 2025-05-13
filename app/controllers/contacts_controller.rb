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
    puts params
  end

  def send_message
    if params[:receipients] == "contact_affiliation"
      if Contact.find(params[:contact_id]).name != params[:contact_name]
        redirect_back_or_to root_path
      end
    end
    puts MessageHandler.init(params)
    redirect_back_or_to root_path
  end

  def import_contacts
  end

  def import
    require "csv"
    file = params[:file]
    status = []
    skipped_missing_data = []
    CSV.foreach(file, headers: true) do |row|
      h = row.to_hash
      puts h
      h = h.transform_keys { |k| k == "year_came" ? "year_entered" : k }
      h = h.transform_keys { |k| k== "Name" ? "name" : k }
      if h.key?("name") && h["name"] != nil && h["name"] != "" && h.key?("phone") && h["phone"] != nil && h["phone"] != "" && h.key?("year_entered") && h["year_entered"] != nil && h["year_entered"] != "" || h.key?("name") && h["name"] != nil && h["name"] != "" && h.key?("phone") && h["phone"] != nil && h["phone"] != "" && h.key?("year_entered") && h["year_entered"] != nil && h["year_entered"] != "" && h.key?("year_left") && h["year_left"] != nil && h["year_left"] != ""
        h[:year_entered] = Date.parse(Chronic.parse(h[:year_entered]).to_s) if h[:year_entered].present?
        h[:year_left] = Date.parse(Chronic.parse(h[:year_left]).to_s) if h[:year_left].present?
        contact = Contact.find_or_initialize_by(h)
        if contact.save
          puts "saved"
          status << "saved"
        else
          puts "not saved or something went wrong"
          status << "not saved"
        end
      else
        puts "missing data"
        status << "missing data"
        skipped_missing_data << h
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
