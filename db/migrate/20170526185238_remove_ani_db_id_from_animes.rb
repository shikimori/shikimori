class RemoveAniDbIdFromAnimes < ActiveRecord::Migration[5.0]
  def change
    remove_column :animes, :ani_db_id, :integer, default: 0
  end
end
