class RemoveBirthdatFromContact < ActiveRecord::Migration[8.0]
  def change
    remove_column :contacts, :birthday
  end
end
