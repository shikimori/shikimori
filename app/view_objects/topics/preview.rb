class Topics::Preview < Topics::View
  is_preview true

  def review_preview?
    topic.review?
  end

  def css_classes
    super.push 'preview'
  end

  def show_body?
    true
  end
end
