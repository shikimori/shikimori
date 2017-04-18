class CreateCollectionsForum < ActiveRecord::Migration[5.0]
  def up
    Forum.create!(
      id: 14,
      position: 14,
      name_ru: 'Коллекции',
      permalink: 'collections',
      is_visible: false,
      name_en: 'Collections'
    )
  end

  def down
    Forum.find(14).destroy
    Topic.where(forum_id: 14).destroy_all
  end
end
