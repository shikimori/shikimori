class CharacterComment < AniMangaComment
  # текст топика
  def text
    "Обсуждение [character=#{self.linked_id}]персонажа[/character]."
  end
end
