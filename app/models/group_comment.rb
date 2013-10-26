class GroupComment < AniMangaComment
  # текст топика
  def text
    self[:text] || "Топик [group=#{self.linked_id}]клуба[/group]."
  end
end
