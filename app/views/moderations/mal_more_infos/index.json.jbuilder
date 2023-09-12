json.content JsExports::Supervisor.instance.sweep(
  current_user,
  render(
    partial: 'moderations/mal_more_infos/more_info_line',
    collection: @collection,
    as: :entry,
    formats: :html
  )
)

if @animes_collection.next_page? || @mangas_collection.next_page?
  json.postloader render(
    partial: 'blocks/postloader',
    locals: {
      next_url: current_url(page: page + 1),
      prev_url: current_url(page: page - 1)
    },
    formats: :html
  )
end

json.JS_EXPORTS JsExports::Supervisor.instance.export(current_user)
