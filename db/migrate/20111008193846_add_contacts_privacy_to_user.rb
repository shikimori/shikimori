class AddContactsPrivacyToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :contacts_privacy, :string, :default => ContactsPrivacy::Users
  end

  def self.down
    remove_column :users, :contacts_privacy
  end
end
