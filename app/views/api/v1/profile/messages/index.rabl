collection @resources

attribute :id, :kind, :read, :body, :created_at

node :html_body do |message|
  get_message_body message
end

child :from do |user|
  attributes :id, :nickname

  node :avatar do |user|
    user.avatar_url 48
  end
end

child :to do |user|
  attributes :id, :nickname

  node :avatar do |user|
    user.avatar_url 48
  end
end

child linked: :linked do |linked|
  attributes :id, :type

  if linked && linked.kind_of?(Entry)
    node(:url) { topic_url linked }

    child linked: :linked do |linked|
      node(:type) {|v| v.class.name }

      if linked.kind_of? Anime

        attributes :id, :name, :russian

        node :image do |entry|
          {
            preview: entry.image.url(:preview),
            short: entry.image.url(:short),
            x96: entry.image.url(:x96),
            x64: entry.image.url(:x64),
          }
        end

        node :url do |entry|
          anime_url entry
        end
      else
        attributes :id, :name, :russian

        node :image do |entry|
          {
            preview: entry.image.url(:preview),
            short: entry.image.url(:short),
            x96: entry.image.url(:x96),
            x64: entry.image.url(:x64),
          }
        end

        node :url do |entry|
          manga_url entry
        end
      end
    end
  else
    node(:type) { linked.class.name }
    node(:url) { "#{topic_url linked.commentable}#comment-#{linked.id}" } if linked.kind_of? Comment
  end
end
