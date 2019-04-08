json.array! @collection.reverse do |entry|
  json.data entry.id
  json.value entry.nickname
  json.label render('users/suggest', user: entry)
  json.url profile_url(entry)
end
