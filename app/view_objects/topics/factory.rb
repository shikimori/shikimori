class Topics::Factory
  REVIEWS_SECTION = 'reviews'

  pattr_initialize :is_preview

  def build entry, section = nil
    if entry.review?
      Topics::ReviewView.new entry, @is_preview, section == REVIEWS_SECTION

    elsif entry.cosplay?
      Topics::CosplayView.new entry, @is_preview

    elsif entry.generated_news?
      Topics::GeneratedNewsView.new entry, @is_preview

    else
      Topics::View.new entry, @is_preview
    end
  end
end
