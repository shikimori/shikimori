json.content render(partial: 'moderation/reviews/review', collection: @processed, formats: :html)

if @add_postloader
  json.postloader render('blocks/postloader', url: page_moderation_reviews_url(page: @page+1))
end
