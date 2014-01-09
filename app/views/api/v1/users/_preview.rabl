attributes :id, :nickname

node :avatar do |user|
  gravatar_url user, 48
end

node :image do |user|
  {
    x160: gravatar_url(user, 160),
    x148: gravatar_url(user, 148),
    x80: gravatar_url(user, 80),
    x64: gravatar_url(user, 64),
    x32: gravatar_url(user, 32),
    x16: gravatar_url(user, 16)
  }
end
