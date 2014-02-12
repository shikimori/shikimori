class AddHostingToVideos < ActiveRecord::Migration
  def change
    add_column :videos, :hosting, :string
  end
end
