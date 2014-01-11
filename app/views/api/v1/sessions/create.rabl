object resource

attributes :id, :nickname, :email

node :avatar do |user|
  user.avatar_url 32
end
