class GroupProfileSerializer < GroupSerializer
  attributes :description, :description_html, :mangas, :characters, :thread_id, :user_role
  has_many :members, :animes, :mangas, :characters, :images

  def thread_id
    object.thread.id
  end
end
