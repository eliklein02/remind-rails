class RenameStudentToContact < ActiveRecord::Migration[8.0]
  def change
    rename_table :students, :contacts
  end
end
