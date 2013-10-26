class ReprocessAvatarsTo160 < ActiveRecord::Migration
  def self.up
    User.all.each { |v|
      ap v.id
      v.avatar.reprocess! if v.avatar.present?
    }
  end

  def self.down
  end
end
