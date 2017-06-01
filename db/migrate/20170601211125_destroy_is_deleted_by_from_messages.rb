class DestroyIsDeletedByFromMessages < ActiveRecord::Migration[5.0]
  def change
    Message.where(is_deleted_by_from: true).delete_all
  end
end
