class AddStateToVideo < ActiveRecord::Migration
  def change
    add_column :anime_videos, :state, :string, null: false, default: :working
  end
end
