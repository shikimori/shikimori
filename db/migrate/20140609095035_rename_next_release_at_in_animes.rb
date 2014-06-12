class RenameNextReleaseAtInAnimes < ActiveRecord::Migration
  def change
    rename_column :animes, :next_release_at, :next_episode_at
  end
end
