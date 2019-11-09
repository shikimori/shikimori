class AddArticlesForum < ActiveRecord::Migration[5.2]
  def change
    Forum.create! id: 21,
      name_ru: 'Статьи',
      name_en: 'Articles',
      permalink: 'articles',
      position: 28
  end

  def down
    Forum.find_by(id: 21)&.destroy
  end
end
