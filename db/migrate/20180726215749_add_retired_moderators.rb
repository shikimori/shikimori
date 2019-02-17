class AddRetiredModerators < ActiveRecord::Migration[5.1]
  def up
    if Rails.env.production?
      User.where(id: [942, 2033, 1483, 94, 11, 188, 31022]).each do |user|
        user.roles << Types::User::Roles[:retired_moderator]
        user.save!
      end
    end
  end
end
