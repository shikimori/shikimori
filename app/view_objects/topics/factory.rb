class Topics::Factory
  REVIEWS_SECTION = 'reviews'

  pattr_initialize :is_preview

  def find entry_id
    build Entry.find(entry_id)
  end

  def build entry, section = nil
    if entry.review?
      if section == REVIEWS_SECTION
        Topics::ReviewView.new entry, true, true
      else
        Topics::ReviewView.new entry, @is_preview, false
      end

    elsif entry.contest?
      Topics::ContestView.new entry, @is_preview

    elsif entry.cosplay?
      Topics::CosplayView.new entry, @is_preview

    elsif entry.generated_news?
      Topics::GeneratedNewsView.new entry, @is_preview

    else
      Topics::View.new entry, @is_preview
    end
  end
end
