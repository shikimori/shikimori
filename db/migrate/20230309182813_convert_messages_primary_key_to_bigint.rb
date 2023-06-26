class ConvertMessagesPrimaryKeyToBigint < ActiveRecord::Migration[6.1]
  def up
    change_column :messages, :id, :bigint
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
