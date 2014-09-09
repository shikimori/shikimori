class PersonComment < AniMangaComment
  # текст топика
  def text
    "Обсуждение [person=#{self.linked_id}]человека[/person]."
  end
end
