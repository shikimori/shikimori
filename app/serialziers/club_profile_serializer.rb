class ClubProfileSerializer < ClubSerializer
  attributes :description, :description_html, :mangas, :characters, :thread_id,
    :topic_id, :user_role
  has_many :members, :animes, :mangas, :characters, :images

  # TODO: deprecated
  def thread_id
    object.topic&.id
  end

  def topic_id
    object.topic&.id
  end
end
