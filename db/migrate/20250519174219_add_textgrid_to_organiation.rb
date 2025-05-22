class AddTextgridToOrganiation < ActiveRecord::Migration[8.0]
  def change
    add_column :organizations, :textrid_account_sid, :string
    add_column :organizations, :textrid_phone_number, :string
  end
end
