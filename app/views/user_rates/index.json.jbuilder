json.content render(
  partial: 'user_rates',
  locals: { library: @library },
  formats: :html
)

if @library.add_postloader?
  json.postloader render('blocks/postloader', next_url: profile_user_rates_url(url_params(page: @page+1)))
end
