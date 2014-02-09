class ReviewComment < AniMangaComment
  def to_s
    title
  end

  # текст топика
  def text
    type = linked.target_type == Anime.name ? 'anime' : 'manga'
    self[:text] || "Обсуждение обзора [#{type}=#{self.linked.target_id}]#{linked.target_type == Anime.name ? 'аниме' : 'манги'}[/#{type}]."
  end

  def generated?
    true
  end
end
