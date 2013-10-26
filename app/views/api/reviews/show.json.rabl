collection @resource

attributes :id, :text, :target_id, :target_type, :overall, :storyline, :music, :characters, :animation, :source

glue :target do
  attribute name: :target_name
  node :target_url do |target|
    url_for target
  end
end

glue :user do |user|
  attribute nickname: :user_nickname
  node :user_avatar do
    gravatar_url user, 48
  end
end

node :hmtl do |review|
  BbCodeService.instance.format_description(review.text, review)
end

node :created_at do |review|
  review.created_at.strftime '%Y-%m-%d %H:%M:%S'
end
