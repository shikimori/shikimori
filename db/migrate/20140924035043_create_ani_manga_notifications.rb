class CreateAniMangaNotifications < ActiveRecord::Migration
  def change
    create_table :ani_manga_notifications do |t|
      t.string :item_id
      t.string :item_type
      t.datetime :created_at
    end
  end
end
