json.content render(partial: 'moderations/reviews/review', collection: @processed, formats: :html)

if @add_postloader
  json.postloader render('blocks/postloader', next_url: page_moderations_reviews_url(page: @page+1))
end
