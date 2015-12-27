class FixClubImages < ActiveRecord::Migration
  def up
    Image.where(owner_type: 'Group').update_all owner_type: 'Club'
  end
end
