class Topics::EntryTopics::AnimeTopic < Topics::EntryTopic
  # текст топика
  def text
    #"Обсуждение %s [%s]%d[/%s]." % [self.linked_type == Anime.name ? 'аниме' : 'манги', self.linked_type.downcase, self.linked_id, self.linked_type.downcase]
    "Обсуждение [%s=%d]%s[/%s]." % [self.linked_type.downcase, self.linked_id, self.linked_type == Anime.name ? 'аниме' : 'манги', self.linked_type.downcase]
  end
end
