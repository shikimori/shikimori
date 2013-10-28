object resource

attributes :id, :nickname, :email

node :avatar do |user|
  gravatar_url user, 32
end
