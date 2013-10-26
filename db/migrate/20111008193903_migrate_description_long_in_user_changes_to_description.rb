class MigrateDescriptionLongInUserChangesToDescription < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.connection.execute("update user_changes set `column`='description' where `column`='description_long'")
  end

  def self.down
  end
end
