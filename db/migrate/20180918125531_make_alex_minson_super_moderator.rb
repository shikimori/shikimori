class MakeAlexMinsonSuperModerator < ActiveRecord::Migration[5.2]
  def up
    return if Rails.env.test?
    user.update! roles: user.roles.values + [Types::User::Roles[:super_moderator].to_s]
  end

  def down
    return if Rails.env.test?
    user.update! roles: user.roles.values - [Types::User::Roles[:super_moderator].to_s]
  end

private

  def user
    @user ||= User.find(16148)
  end
end
