class AddCarrierToContact < ActiveRecord::Migration[8.0]
  def change
    add_column :contacts, :carrier, :string
  end
end
