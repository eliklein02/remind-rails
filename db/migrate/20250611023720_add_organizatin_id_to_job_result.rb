class AddOrganizatinIdToJobResult < ActiveRecord::Migration[8.0]
  def change
    add_column :job_results, :organization_id, :integer
    add_column :job_results, :failed_to_send_to, :text
    add_column :job_results, :sent_to, :text
  end
end
