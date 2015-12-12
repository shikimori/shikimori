json.content render(
  partial: 'topics/topic',
  collection: @collection,
  as: :view,
  formats: :html
)

if @add_postloader
  json.postloader render(
    'blocks/postloader',
    filter: 'b-topic',
    next_url: section_url(page: @page+1, section: @section[:permalink], linked: params[:linked]),
    prev_url: @page > 1 ? section_url(page: @page-1, section: @section[:permalink], linked: params[:linked]) : nil
  )
end
