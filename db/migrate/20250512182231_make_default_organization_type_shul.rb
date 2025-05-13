class MakeDefaultOrganizationTypeShul < ActiveRecord::Migration[8.0]
  def change
    change_column_default :organizations, :organization_type, from: nil, to: 1
  end
end
