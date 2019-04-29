json.array! @collection.reverse do |club|
  json.data club.id
  json.value club.name
  json.label render('suggest', club: club)
  json.url club_url(club)
end
