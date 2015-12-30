class MigrateTopicsWithOldWallSyntax < ActiveRecord::Migration
  def up
    Topic
      .where("text like '%[/wall]' and value is not null and value != ''")
      .each { |v| v.update wall_ids: v.value.split(',') }
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
