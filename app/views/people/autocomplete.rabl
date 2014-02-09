collection @items
attribute id: :data
attribute name: :value

node :label do |item|
  render_to_string({
      partial: 'characters/suggest',
      formats: :html,
      layout: false,
      locals: {
        character: item,
        url_builder: "#{params[:kind]}_url",
      }
    })
end
