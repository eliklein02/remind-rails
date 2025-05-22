class AddTextgridNotTextrid < ActiveRecord::Migration[8.0]
  def change
    remove_column :organizations, :textrid_account_sid
    remove_column :organizations, :textrid_phone_number
    add_column :organizations, :textgrid_account_sid, :string
    add_column :organizations, :textgrid_phone_number, :string
  end
end
