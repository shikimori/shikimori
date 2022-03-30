json.content render(
  partial: 'user_rates',
  locals: {
    library: @library,
    profile_view: @view
  },
  formats: :html
)

if @library.add_postloader?
  json.postloader render(
    partial: 'blocks/postloader',
    locals: {
      next_url: current_url(page: @page + 1)
    },
    formats: :html
  )
end
