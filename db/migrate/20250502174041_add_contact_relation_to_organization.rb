class AddContactRelationToOrganization < ActiveRecord::Migration[8.0]
  def change
    add_column :contacts, :organization_id, :integer
  end
end
