module SEO
  def noindex
    set_meta_tags noindex: true
  end

  def nofollow
    set_meta_tags nofollow: true
  end

  def description(text)
    set_meta_tags description: text
  end

  def keywords(text)
    set_meta_tags keywords: text
  end
end
