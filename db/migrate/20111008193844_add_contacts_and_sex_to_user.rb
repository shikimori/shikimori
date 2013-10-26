class AddContactsAndSexToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :jabber, :string
    add_column :users, :icq, :string
    add_column :users, :skype, :string
    add_column :users, :mail, :string
    add_column :users, :sex, :string
  end

  def self.down
    remove_column :users, :sex
    remove_column :users, :mail
    remove_column :users, :skype
    remove_column :users, :icq
    remove_column :users, :jabber
  end
end
