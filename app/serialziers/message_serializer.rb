class MessageSerializer < ActiveModel::Serializer
  include TopicsHelper

  attributes :id, :kind, :read, :body, :created_at, :linked
  has_one :from
  has_one :to

  def linked
    return nil unless object.linked
    hash = { id: object.linked.id }

    if object.linked && object.linked.kind_of?(Entry)
      hash[:topic_url] = topic_url object.linked
      hash[:type] = object.linked.type

      if object.linked.linked
        hash[:type] = object.linked.linked.class.name

        if object.linked.linked.kind_of? Anime
          hash.merge! AnimeSerializer.new(object.linked.linked).attributes
        elsif object.linked.linked.kind_of? Manga
          hash.merge! MangaSerializer.new(object.linked.linked).attributes
        end
      end

    else
      hash[:type] = object.linked.class.name
      hash[:topic_url] = "#{topic_url object.linked.commentable}#comment-#{object.linked.id}" if object.linked.kind_of? Comment
    end

    hash
  end
end
