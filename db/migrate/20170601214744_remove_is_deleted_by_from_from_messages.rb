class RemoveIsDeletedByFromFromMessages < ActiveRecord::Migration[5.0]
  def change
    remove_column :messages, :is_deleted_by_from, :boolean
    add_index :messages, %i[from_id kind], name: :private_and_notifications
  end
end
