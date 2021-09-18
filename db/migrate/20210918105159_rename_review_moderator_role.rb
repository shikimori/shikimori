class RenameReviewModeratorRole < ActiveRecord::Migration[5.2]
  def up
    User.where("roles && '{review_moderator}'").each do |user|
      user.roles << :critique_moderator
      user.save!
    end
  end

  def down
    User.where("roles && '{critique_moderator}'").each do |user|
      user.roles << :review_moderator
      user.save!
    end
  end
end
