json.content render(partial: 'moderation/bans/ban', collection: @bans, formats: :html)

if @add_postloader
  json.postloader render('blocks/postloader', url: page_moderation_bans_url(page: @page+1))
end
