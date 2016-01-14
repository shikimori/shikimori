class Topics::EntryTopics::CharacterTopic < Topics::EntryTopic
  def text
    "Обсуждение [character=#{self.linked_id}]персонажа[/character]."
  end
end
