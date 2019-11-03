class AssignArticlesModeratorRole < ActiveRecord::Migration[5.2]
  def change
    User.where(id: [16148]).each do |user|
      user.roles.push Types::User::Roles[:article_moderator]
      user.save!
    end
  end
end
