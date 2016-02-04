class AnimeVideoSerializer < ActiveModel::Serializer
  attributes :id, :anime_id, :url, :source, :episode, :kind, :language,
    :state, :author_name
end
