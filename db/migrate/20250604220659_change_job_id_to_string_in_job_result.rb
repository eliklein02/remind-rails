class ChangeJobIdToStringInJobResult < ActiveRecord::Migration[8.0]
  def change
    change_column :job_results, :job_id, :string, null: false, default: ""
  end
end
