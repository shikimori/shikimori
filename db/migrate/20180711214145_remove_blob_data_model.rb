class RemoveBlobDataModel < ActiveRecord::Migration[5.1]
  def change
    drop_table :blob_datas
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
