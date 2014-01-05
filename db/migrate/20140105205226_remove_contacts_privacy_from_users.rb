class RemoveContactsPrivacyFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :contacts_privacy
  end

  def down
    add_column :users, :contacts_privacy, :string
  end
end
