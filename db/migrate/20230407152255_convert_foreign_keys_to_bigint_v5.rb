class ConvertForeignKeysToBigintV5 < ActiveRecord::Migration[6.1]
  TABLES = {
    comments: %i[id commentable_id user_id],
    topics: %i[id user_id forum_id],
  }

  def up
    TABLES.each do |table, fields|
      Array(fields).each do |field|
        change_column table, field, :bigint
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
