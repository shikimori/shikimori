class AddRawToComment < ActiveRecord::Migration
  def self.up
    add_column :comments, :html_body, :text
    Comment.all.each {|v| v.update_attribute(:body, v.body) }
  end

  def self.down
    remove_column :comments, :raw
  end
end
