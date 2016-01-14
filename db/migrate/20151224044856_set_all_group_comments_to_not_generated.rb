class SetAllGroupCommentsToNotGenerated < ActiveRecord::Migration
  def up
    Entry.where(type: 'ClubComment').update_all generated: false
  end

  def down
    Entry.where(type: 'ClubComment').update_all generated: true
  end
end
