class RenameDelFieldsInMessages < ActiveRecord::Migration
  def change
    rename_column :messages, :src_del, :is_deleted_by_from
    rename_column :messages, :dst_del, :is_deleted_by_to
  end
end
