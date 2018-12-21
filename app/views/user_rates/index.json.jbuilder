json.content render(
  partial: 'user_rates',
  locals: { library: @library, profile_view: @view },
  formats: :html
)

if @library.add_postloader?
  json.postloader render(
    'blocks/postloader',
    next_url: current_url(page: @page + 1)
  )
end
