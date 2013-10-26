class AddSubjectToMessages < ActiveRecord::Migration
  def self.up
    add_column :messages, :subject, :string
  end

  def self.down
    remove_column :messages, :subject
  end
end
