json.array! @collection do |entry|
  json.data entry.id
  json.value entry.nickname
  json.label render('users/suggest', user: entry)
  json.url user_url(entry)
end
