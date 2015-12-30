class MigrateTopicsWithOldWallSyntax < ActiveRecord::Migration
  def up
    Entry.record_timestamps = false
    Entry
      .where("text like '%[/wall]' and value is not null and value != ''")
      .each { |v| v.update wall_ids: v.value.split(',') }
    Entry.record_timestamps = true
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
