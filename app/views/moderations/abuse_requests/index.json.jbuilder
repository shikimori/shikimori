json.content render(@processed, formats: :html)

if @add_postloader
  json.postloader render(
    'blocks/postloader',
    next_url: current_url(page: @page + 1),
    prev_url: @page > 1 ? current_url(page: @page - 1) : nil
  )
end
