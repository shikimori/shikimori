json.title @page_title
json.notice @title_notice

json.content UserRates::Tracker.instance.sweep(render(
  partial: 'animes_collection/cached_collection',
  locals: { view: @view },
  formats: :html
))
json.current_page @view.page
json.total_pages @view.pages_count
json.next_page_url @view.next_page_url
json.prev_page_url @view.prev_page_url

if user_signed_in?
  json.tracked_user_rates UserRates::Tracker.instance.export(current_user)
end
