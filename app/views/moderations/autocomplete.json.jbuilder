json.array! @collection.reverse do |entry|
  json.data entry.id
  json.value entry.nickname
  json.label render(
    partial: 'users/suggest',
    locals: {
      user: entry
    },
    formats: :html
  )
  json.url profile_url(entry)
end
