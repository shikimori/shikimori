json.title @page_title
json.notice @title_notice

json.content render(
  partial: 'userlist_comparer/table.html',
  formats: :html
)
json.current_page @current_page
json.total_pages @total_pages
json.next_page @next_page
json.prev_page @prev_page
