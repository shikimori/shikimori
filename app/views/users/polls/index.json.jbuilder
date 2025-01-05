json.content JsExports::Supervisor.instance.sweep(
  current_user,
  render(
    partial: 'users/polls/poll',
    collection: @collection,
    locals: {
      user: @user
    },
    formats: :html
  )
)

if @collection.next_page
  json.postloader render(
    partial: 'blocks/postloader',
    locals: {
      next_url: current_url(page: @collection.next_page),
      prev_url: @collection.prev_page ?
        current_url(page: @collection.prev_page) : nil
    },
    formats: :html
  )
end

json.JS_EXPORTS JsExports::Supervisor.instance.export(current_user)
