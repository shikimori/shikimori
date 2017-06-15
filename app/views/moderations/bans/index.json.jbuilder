json.content render(partial: 'moderations/bans/ban', collection: @bans, formats: :html)

if @add_postloader
  json.postloader render('blocks/postloader', next_url: moderations_bans_url(page: @page+1))
end
