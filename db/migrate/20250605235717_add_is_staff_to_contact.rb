class AddIsStaffToContact < ActiveRecord::Migration[8.0]
  def change
    add_column :contacts, :is_staff, :boolean, default: false
  end
end
