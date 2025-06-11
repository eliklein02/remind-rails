class AddOriginalMessageToJobResult < ActiveRecord::Migration[8.0]
  def change
    add_column :job_results, :original_message, :text
  end
end
