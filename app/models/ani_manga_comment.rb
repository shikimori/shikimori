class AniMangaComment < DbEntryThread
  include ActionView::Helpers::UrlHelper

  def sync
    self.title = linked.name if linked[:name].present?
  end

  # текст топика
  def text
    #"Обсуждение %s [%s]%d[/%s]." % [self.linked_type == Anime.name ? 'аниме' : 'манги', self.linked_type.downcase, self.linked_id, self.linked_type.downcase]
    "Обсуждение [%s=%d]%s[/%s]." % [self.linked_type.downcase, self.linked_id, self.linked_type == Anime.name ? 'аниме' : 'манги', self.linked_type.downcase]
  end

  def to_s
    'Обсуждение'
  end
end
