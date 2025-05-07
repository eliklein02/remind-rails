class PagesController < ApplicationController
  def home
    @contacts = Contact.all.sort_by { |c| c.name.to_s }
  end

  def about
  end

  def new_message
    @contacts = Contact.all.sort_by { |c| c.name.to_s }
  end
end
