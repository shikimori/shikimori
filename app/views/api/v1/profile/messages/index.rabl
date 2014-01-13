collection @resources

attribute :id, :kind, :read, :body, :created_at

node :html_body do |message|
  get_message_body message
end

child from: :from do
  extends 'api/v1/users/preview'
end

child to: :to do
  extends 'api/v1/users/preview'
end

child linked: :linked do |linked|
  attributes :id, :type

  if linked && linked.kind_of?(Entry)
    node(:url) { topic_url linked }

    child linked: :linked do |linked|
      node(:type) {|v| v.class.name }

      if linked.kind_of? Anime
        extends 'api/v1/animes/preview'
      else
        extends 'api/v1/mangas/preview'
      end
    end
  else
    node(:type) { linked.class.name }
    node(:url) { "#{topic_url linked.commentable}#comment-#{linked.id}" } if linked.kind_of? Comment
  end
end
