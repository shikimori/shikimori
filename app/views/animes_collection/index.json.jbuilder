json.title @page_title
json.notice @title_notice

json.content JsExports::Supervisor.instance.sweep(render(
  partial: 'animes_collection/cached_collection',
  locals: { view: @view },
  formats: :html
))
json.page @view.page
json.pages_count @view.pages_count
json.next_page_url @view.next_page_url
json.prev_page_url @view.prev_page_url

json.JS_EXPORTS(user_signed_in? ? JsExports::Supervisor.instance.export : {})
