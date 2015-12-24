class ClubComment < AniMangaComment
  include PermissionsPolicy

  # текст топика
  def text
    self[:text] || "Топик [club=#{self.linked_id}]клуба[/club]."
  end
end
