class CreateSvds < ActiveRecord::Migration
  def change
    create_table :svds do |t|
      t.binary :entry_ids, :limit => 1.megabyte
      t.binary :lsa, :limit => 10.megabyte

      t.timestamps
    end
  end
end
