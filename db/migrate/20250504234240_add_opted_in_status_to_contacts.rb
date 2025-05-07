class AddOptedInStatusToContacts < ActiveRecord::Migration[8.0]
  def change
    add_column :contacts, :opted_in_status, :integer, default: 0
  end
end
