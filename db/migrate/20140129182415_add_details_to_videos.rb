class AddDetailsToVideos < ActiveRecord::Migration
  def change
    add_column :videos, :details, :text
  end
end
