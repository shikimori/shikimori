collection @resources

attributes :id, :nickname
node :avatar do |user|
  gravatar_url user, 48
end
