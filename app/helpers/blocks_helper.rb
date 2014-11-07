module BlocksHelper
  def block_to_partial partial_name, options = {}, &block
    options.merge! body: capture(&block)
    render partial: partial_name, locals: options, formats: :html
  end

  def spoiler title, options = {display: :block}, &block
    block_to_partial 'blocks/spoiler', options.merge(title: title), &block
  end
end
