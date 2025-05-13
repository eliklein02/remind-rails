class AddNameToOrganization < ActiveRecord::Migration[8.0]
  def change
    add_column :organizations, :name, :string, default: "", null: false
  end
end
