class MakeAlexMinsonSuperModerator < ActiveRecord::Migration[5.2]
  def up
    if Rails.env.production?
      user.update! roles: user.roles.values + [Types::User::Roles[:super_moderator].to_s]
    end
  end

  def down
    if Rails.env.production?
      user.update! roles: user.roles.values - [Types::User::Roles[:super_moderator].to_s]
    end
  end

private

  def user
    @user ||= User.find(16148)
  end
end
