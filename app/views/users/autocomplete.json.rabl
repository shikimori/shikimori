collection @items
attribute :id => :data
attribute :nickname => :value

node :label do |item|
  render_to_string({
      partial: 'users/suggest',
      formats: :html,
      layout: false,
      locals: {
        user: item
      }
    })
end
