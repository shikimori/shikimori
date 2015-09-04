json.content render(partial: 'moderations/bans/ban', collection: @bans, formats: :html)

if @add_postloader
  json.postloader render('blocks/postloader', url: page_moderations_bans_url(page: @page+1))
end
