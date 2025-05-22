class AddContactIdToMessageSents < ActiveRecord::Migration[8.0]
  def change
    add_column :message_sents, :contact_id, :integer
  end
end
