class ModifyMalIdOfGenreV2 < ActiveRecord::Migration[7.0]
  def up
    change_column :genres_v2, :mal_id, :bigint, null: true
  end

  def down
    change_column :genres_v2, :mal_id, :bigint, null: false
  end
end
