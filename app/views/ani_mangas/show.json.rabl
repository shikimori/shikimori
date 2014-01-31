object nil

node(:title_page) { @page_title }

node :content do
  render_to_string(
    partial: @director.partial,
    layout: false
  )
end
