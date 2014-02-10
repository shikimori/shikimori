collection @items
attribute :id => :data
attribute :name => :value

node :label do |item|
  render_to_string({
      partial: 'danbooru/suggest',
      formats: :html,
      layout: false,
      locals: {
        entry: item
      }
    })
end

