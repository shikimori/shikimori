class CreateReviewsForum < ActiveRecord::Migration[5.2]
  def up
    Forum.find_or_create_by(
      id: 24,
      position: 23,
      name_ru: 'Отзывы',
      name_en: 'Reviews',
      permalink: 'reviews',
    )
  end

  def down
    Forum.find_by(id: 24).destroy
  end
end
