class AddMenuContestToProfileSettings < ActiveRecord::Migration
  def self.up
    add_column :profile_settings, :menu_contest, :boolean, default: true, null: false
  end

  def self.down
    remove_column :profile_settings, :menu_contest
  end
end
