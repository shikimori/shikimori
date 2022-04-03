json.array! @collection.reverse do |club|
  json.data club.id
  json.value club.name
  json.label render(
    partial: 'suggest',
    locals: {
      club: club
    },
    formats: :html
  )
  json.url club_url(club)
end
