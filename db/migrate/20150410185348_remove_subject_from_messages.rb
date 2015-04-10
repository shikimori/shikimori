class RemoveSubjectFromMessages < ActiveRecord::Migration
  def change
    remove_column :messages, :subject, :string, limit: 255
  end
end
