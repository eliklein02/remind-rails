class AddCityAndCountry < ActiveRecord::Migration[8.0]
  def change
    add_column :organizations, :city, :string
    add_column :organizations, :country, :string
    # add_index :users, [:city, :country]
  end
end
