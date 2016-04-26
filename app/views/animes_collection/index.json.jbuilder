json.title @page_title
json.notice @title_notice

json.content UserRates::Tracker.instance.sweep(render(
  partial: 'animes_collection/entries',
  formats: :html
))
json.current_page @current_page
json.total_pages @total_pages
json.next_page @next_page
json.prev_page @prev_page

if user_signed_in?
  json.tracked_user_rates UserRates::Tracker.instance.export(current_user)
end
