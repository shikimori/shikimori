class Topics::EntryTopics::MangaTopic < Topics::EntryTopic
  def text
    "Обсуждение [%s=%d]%s[/%s]." % [self.linked_type.downcase, self.linked_id, self.linked_type == Anime.name ? 'аниме' : 'манги', self.linked_type.downcase]
  end
end
