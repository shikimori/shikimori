class AddSourceToReviews < ActiveRecord::Migration
  def self.up
    add_column :reviews, :source, :string
  end

  def self.down
    remove_column :reviews, :source
  end
end
