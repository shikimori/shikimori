json.title @title
json.description @description
json.content render(partial: 'animes_collection/entries', formats: :html)
json.current_page @current_page
json.total_pages @total_pages
json.next_page @next_page
json.prev_page @prev_page
