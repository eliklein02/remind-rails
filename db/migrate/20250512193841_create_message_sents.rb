class CreateMessageSents < ActiveRecord::Migration[8.0]
  def change
    create_table :message_sents do |t|
      t.integer :organization_id

      t.timestamps
    end
  end
end
