class RemoveYearOptionFromContact < ActiveRecord::Migration[8.0]
  def change
    remove_column :contacts, :year_entered, :integer if column_exists?(:contacts, :year_entered)
    remove_column :contacts, :year_left, :integer if column_exists?(:contacts, :year_left)
  end
end
