module BlocksHelper
  def block_to_partial partial_name, options = {}, &block
    options[:body] = capture(&block)
    render partial: partial_name, locals: options, formats: :html
  end

  def spoiler title, options = { display: :block }, &block
    block_to_partial 'blocks/spoiler', options.merge(title: title), &block
  end

  def text_spoiler title, &block
    block_to_partial 'blocks/text_spoiler', title: title, &block
  end
end
