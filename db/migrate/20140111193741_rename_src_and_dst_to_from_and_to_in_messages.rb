class RenameSrcAndDstToFromAndToInMessages < ActiveRecord::Migration
  def up
    rename_column :messages, :src_id, :from_id
    rename_column :messages, :dst_id, :to_id
    remove_column :messages, :src_type
    remove_column :messages, :dst_type
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
