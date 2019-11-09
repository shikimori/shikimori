class CreateNewsForum < ActiveRecord::Migration[5.2]
  def up
    Forum.create! id: 20,
      name_ru: 'Новости',
      name_en: 'News',
      permalink: 'News',
      position: 5,
      is_visible: false
  end

  def down
    Forum.find_by(id: 20)&.destroy
  end
end
