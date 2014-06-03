class GroupComment < AniMangaComment
  include PermissionsPolicy

  # текст топика
  def text
    self[:text] || "Топик [group=#{self.linked_id}]клуба[/group]."
  end
end
