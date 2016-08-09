json.title @page_title
json.notice @title_notice

json.content JsExports.instance.sweep(render(
  partial: 'animes_collection/cached_collection',
  locals: { view: @view },
  formats: :html
))
json.page @view.page
json.pages_count @view.pages_count
json.next_page @view.next_page_url
json.prev_page @view.prev_page_url

if user_signed_in?
  json.tracked_user_rates UserRates::Tracker.instance.export(current_user)
end
