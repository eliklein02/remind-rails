class AddTextToMessageSents < ActiveRecord::Migration[8.0]
  def change
    add_column :message_sents, :body, :string
  end
end
