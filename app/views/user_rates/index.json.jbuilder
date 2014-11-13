json.content render('user_rates')

if @resource.list.add_postloader?
  json.postloader render('blocks/postloader', url: profile_user_rates_url(url_params(page: @page+1)))
end
