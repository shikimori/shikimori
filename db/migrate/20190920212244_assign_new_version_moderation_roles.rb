class AssignNewVersionModerationRoles < ActiveRecord::Migration[5.2]
  def change
    User.where(id: [16148, 21887]).each do |user|
      user.roles.push Types::User::Roles[:version_texts_moderator]
      user.save!
    end

    User.where(id: [30214, 178211]).each do |user|
      user.roles.push Types::User::Roles[:version_fansub_moderator]
      user.save!
    end

    Version.where(id: [642322, 635873]).destroy_all
  end
end
