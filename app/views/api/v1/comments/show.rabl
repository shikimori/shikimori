object @resource

attributes :id, :user_id, :commentable_id, :commentable_type
attributes :body, :html_body, :created_at, :updated_at
attributes :offtopic, :review

child :user do
  attributes :id, :nickname
  node :avatar do |user|
    gravatar_url user, 48
  end
end
