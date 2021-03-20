class MessageSerializer < ActiveModel::Serializer
  attributes :id, :kind, :read, :body, :html_body, :created_at, :linked_id, :linked_type, :linked
  has_one :from
  has_one :to

  def body
    object.body || object.linked&.to_s
  end

  def html_body
    return if object.broken?

    object.generate_body.gsub(%r{(?<!:)//(?=\w)}, 'http://')
  end

  def linked
    return unless object.linked

    hash = { id: object.linked.id }

    if object.linked.is_a? Topic
      hash[:topic_url] = UrlGenerator.instance.topic_url object.linked

      # TODO: deprecated
      hash[:thread_id] = object.linked_id
      hash[:topic_id] = object.linked_id
      hash[:type] = object.linked.type

      if object.linked.linked
        hash[:type] = object.linked.linked.class.name

        if object.linked.linked.is_a? Anime
          hash.merge! AnimeSerializer.new(object.linked.linked).attributes
        elsif object.linked.linked.is_a? Manga
          hash.merge! MangaSerializer.new(object.linked.linked).attributes
        end
      end

    else
      hash[:type] = object.linked.class.name
      if object.linked.is_a? Comment
        hash[:topic_url] = UrlGenerator.instance.topic_url(object.linked.commentable) +
          "#comment-#{object.linked.id}"

        # TODO: deprecated
        hash[:thread_id] = object.linked.commentable_id
        hash[:topic_id] = object.linked.commentable_id
      end
    end

    hash
  end
end
