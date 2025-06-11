class AddTextgridAuthToken < ActiveRecord::Migration[8.0]
  def change
    add_column :organizations, :textgrid_auth_token, :string
  end
end
