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
    puts hi
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
