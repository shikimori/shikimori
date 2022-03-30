json.content render(
  partial: 'moderations/roles/user',
  collection: @collection,
  locals: {
    with_action: can?(:"manage_#{@role}_role", User),
    role: @role
  },
  formats: :html
)

if @collection&.next_page?
  json.postloader render(
    partial: 'blocks/postloader',
    locals: {
      filter: 'b-user',
      next_url: current_url(page: @collection.next_page),
      prev_url: (
        current_url(page: @collection.prev_page) if @collection.prev_page?
      )
    },
    formats: :html
  )
end
