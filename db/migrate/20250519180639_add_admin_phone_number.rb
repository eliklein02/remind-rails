class AddAdminPhoneNumber < ActiveRecord::Migration[8.0]
  def change
    add_column :organizations, :admin_phone_number, :string
  end
end
