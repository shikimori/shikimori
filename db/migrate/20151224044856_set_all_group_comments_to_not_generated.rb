class SetAllClubCommentsToNotGenerated < ActiveRecord::Migration
  def up
    ClubComment.update_all generated: false
  end

  def down
    ClubComment.update_all generated: true
  end
end
