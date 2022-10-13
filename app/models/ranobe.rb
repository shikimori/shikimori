class Ranobe < Manga
  KINDS = %w[light_novel novel]

  CHAPTER_DURATION = 40
  VOLUME_DURATION = (24 * 60) / 4 # 4 volumes per day - 6 hours per volume

  update_index('ranobe#ranobe') do
    if saved_change_to_name? || saved_change_to_russian? ||
        saved_change_to_english? || saved_change_to_japanese? ||
        saved_change_to_synonyms? || saved_change_to_score? ||
        saved_change_to_kind?
      self
    end
  end

  has_many :club_links, -> { where linked_type: 'Ranobe' },
    inverse_of: :linked,
    foreign_key: :linked_id,
    dependent: :destroy

  has_many :clubs, -> { where is_non_thematic: false },
    through: :club_links
end
