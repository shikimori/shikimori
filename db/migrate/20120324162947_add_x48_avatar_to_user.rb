class AddX48AvatarToUser < ActiveRecord::Migration
  def self.up
    User.all.each { |v| v.avatar.reprocess! }
  end

  def self.down
  end
end
