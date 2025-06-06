class CreateJobResults < ActiveRecord::Migration[8.0]
  def change
    create_table :job_results do |t|
      t.integer :job_id
      t.string :status
      t.string :message

      t.timestamps
    end
  end
end
