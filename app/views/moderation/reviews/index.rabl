object nil

node :content do
  render_to_string(partial: 'moderation/reviews/review', collection: @processed, formats: :html) +
    (@add_postloader ?
      render_to_string(partial: 'site/postloader_new', locals: { url: page_moderation_reviews_url(page: @page+1) }, formats: :html) :
      '')
end
