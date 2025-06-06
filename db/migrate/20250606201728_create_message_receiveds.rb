class CreateMessageReceiveds < ActiveRecord::Migration[8.0]
  def change
    create_table :message_receiveds do |t|
      t.string :from
      t.string :body
      t.string :organization_id, null: false
      t.timestamps
    end
  end
end
