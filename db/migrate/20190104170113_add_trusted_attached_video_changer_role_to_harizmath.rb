class AddTrustedAttachedVideoChangerRoleToHarizmath < ActiveRecord::Migration[5.2]
  def up
    user = User.find_by(id: 4795)

    if user
      user.update roles: user.roles.to_a + %w[trusted_attached_video_changer]
    end
  end

  def down
    user = User.find_by(id: 4795)

    if user
      user.update roles: user.roles.to_a - %w[trusted_attached_video_changer]
    end
  end
end
