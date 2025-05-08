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
    b_day = params["bday"]
    @contact = Contact.new(contact_params)
    @contact.birthday = Date.strptime(b_day, "%m/%d/%Y") if b_day.present?
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
    CSV.foreach(file, headers: true) do |row|
      h = row.to_hash
      puts h
      h = h.transform_keys { |k| k == "year_came" ? "year_entered" : k }
      if h.key?("name") && h["name"] != nil && h["name"] != "" && h.key?("phone") && h["phone"] != nil && h["phone"] != "" && h.key?("year_entered") && h["year_entered"] != nil && h["year_entered"] != "" && h.key?("year_left") && h["year_left"] != nil && h["year_left"] != ""
        contact = Contact.new(h)
        if contact.save
          puts "saved"
        else
          puts "not saved"
        end
      else
        puts "missing data"
      end
      flash[:notice] = "Contacts were successfully added!"
      redirect_to contacts_path and return
    end
  end

  private

  def set_contact
    @contact = Contact.find(params[:id])
  end

  def contact_params
    params.require(:contact).permit(:name, :email, :phone, :year_entered, :year_left, :birthday).tap do |c_p|
      c_p[:year_entered] = Date.strptime(c_p[:year_entered], "%m/%d/%Y") if c_p[:year_entered].present? && c_p[:year_entered].match?(/\d{1,2}\/\d{1,2}\/\d{4}/)
      c_p[:year_left] = Date.strptime(c_p[:year_left], "%m/%d/%Y") if c_p[:year_left].present? && c_p[:year_left].match?(/\d{1,2}\/\d{1,2}\/\d{4}/)
      c_p[:birthday] = Date.strptime(c_p[:birthday], "%m/%d/%Y") if c_p[:birthday].present? && c_p[:birthday].match?(/\d{1,2}\/\d{1,2}\/\d{4}/)
    end
  end
end
