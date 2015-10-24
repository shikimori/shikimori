class Topics::Factory
  pattr_initialize :is_preview

  def build entry
    if entry.review?
      Topics::ReviewView.new entry, @is_preview, false

    elsif entry.cosplay?
      Topics::CosplayView.new entry, @is_preview

    elsif entry.generated_news?
      Topics::GeneratedNewsView.new entry, @is_preview

    else
      Topics::View.new entry, @is_preview
    end
  end
end
