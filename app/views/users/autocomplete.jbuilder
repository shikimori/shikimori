json.array! @collection do |entry|
  json.data entry.id
  json.value entry.nickname
  json.label render('suggest', user: entry)
  json.url profile_url(entry)
end
