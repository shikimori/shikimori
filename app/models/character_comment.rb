class CharacterComment < AniMangaComment
  # текст топика
  def text
    "Обсуждение [#{self.linked_type.downcase}=#{self.linked_id}]персонажа[/#{self.linked_type.downcase}]."
  end
end
