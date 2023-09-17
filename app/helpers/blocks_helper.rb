module BlocksHelper
  def block_to_partial(partial_name, options = {}, &)
    options[:body] = capture(&)
    render partial: partial_name, locals: options, formats: :html
  end

  def spoiler(title, options = { display: :block }, &)
    block_to_partial('blocks/spoiler', options.merge(title:), &)
  end

  def text_spoiler(title, is_expanded: false, &)
    if is_expanded
      capture(&)
    else
      block_to_partial('blocks/text_spoiler', title:, &)
    end
  end
end
