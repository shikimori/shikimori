class ChangeReviewsForumToCritiquesForum < ActiveRecord::Migration[5.2]
  def up
    Forum.find_by(id: 12)&.update! permalink: 'critiques', name_en: 'Critiques'
  end

  def down
    Forum.find_by(id: 12)&.update! permalink: 'reviews', name_en: 'Reviews'
  end
end
