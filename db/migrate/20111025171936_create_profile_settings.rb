class CreateProfileSettings < ActiveRecord::Migration
  def self.up
    create_table :profile_settings do |t|
      t.integer :user_id
      t.boolean :anime, :default => true
      t.boolean :manga, :default => true

      t.timestamps
    end
    add_index :profile_settings, :user_id
    User.all.each do |user|
      user.profile_settings = ProfileSettings.create(:user => user)
    end
  end

  def self.down
    drop_table :profile_settings
  end
end
