class RemoveYearOptionFromContact < ActiveRecord::Migration[8.0]
  def change
    remove_column :contacts, :year_entered, :integer
    remove_column :contacts, :year_left, :integer
  end
end
