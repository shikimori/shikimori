object nil

node :title_page do
  @page_title
end
node :content do
  render_to_string({
      partial: @director.partial,
      layout: false
    })
end
