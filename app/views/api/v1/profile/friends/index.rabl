collection @resources

attributes :id, :nickname
node :avatar do |user|
  user.avatar_url 48
end
