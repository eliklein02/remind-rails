class AddTextgridEncodedToOrganization < ActiveRecord::Migration[8.0]
  def change
    add_column :organizations, :encoded_textgrid_credentials, :string
  end
end
