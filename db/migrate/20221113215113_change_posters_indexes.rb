class ChangePostersIndexes < ActiveRecord::Migration[6.1]
  def change
    %i[anime_id character_id manga_id person_id].each do |field|
      remove_index :posters, [field]
      add_index :posters, [field],
        where: "#{field} is not null and is_approved=true and deleted_at is null",
        unique: true
    end
  end
end
