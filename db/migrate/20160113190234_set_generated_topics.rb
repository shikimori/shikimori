class SetGeneratedTopics < ActiveRecord::Migration
  def change
    Entry
      .where(type: ['ReviewComment', 'ClubComment', 'ContestComment', 'CosplayComment'])
      .update_all(title: nil, body: nil, generated: true)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
