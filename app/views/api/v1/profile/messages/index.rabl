collection @resources

attribute :id, :kind, :read, :body, :created_at

node :html_body do |message|
  get_message_body message
end

child src: :from do
  extends 'api/v1/users/preview'
end

child dst: :to do
  extends 'api/v1/users/preview'
end

child linked: :linked do |linked|
  attributes :id, :type

  node :url do
    topic_url linked if linked
  end

  child linked: :linked do |linked|
    node(:type) {|v| v.class.name }

    if linked.kind_of? Anime
      extends 'api/v1/animes/preview'
    else
      extends 'api/v1/mangas/preview'
    end
  end
end
