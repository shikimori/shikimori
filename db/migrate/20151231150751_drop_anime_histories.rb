class DropAnimeHistories < ActiveRecord::Migration
  def change
    drop_table :anime_histories
  end
end
