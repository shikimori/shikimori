json.content JsExports::Supervisor.instance.sweep(render(
  partial: 'comments/comment',
  collection: @collection,
  formats: :html
))

json.postloader render(
  'blocks/postloader',
  filter: 'b-comment',
  next_url: comments_profile_url(page: @page+1, search: params[:search])
) if @add_postloader

json.JS_EXPORTS JsExports::Supervisor.instance.export(current_user)
