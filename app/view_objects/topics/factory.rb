class Topics::Factory
  pattr_initialize :is_preview, :is_mini

  def find entry_id
    build Entry.find(entry_id)
  end

  def build entry
    if entry.review?
      Topics::ReviewView.new entry, @is_preview, @is_mini

    elsif entry.contest?
      Topics::ContestView.new entry, @is_preview, @is_mini

    elsif entry.cosplay?
      Topics::CosplayView.new entry, @is_preview, @is_mini

    elsif entry.generated_news?
      Topics::GeneratedNewsView.new entry, @is_preview, @is_mini

    elsif entry.news?
      Topics::NewsView.new entry, @is_preview, @is_mini

    else
      Topics::View.new entry, @is_preview, @is_mini
    end
  end
end
