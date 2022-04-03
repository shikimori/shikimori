class ImageReloader < ServiceObjectBase
  pattr_initialize :entry

  def call
    return if entry.desynced.include? 'image'
    return unless parsed_data && parsed_data[:image]

    @entry.update(
      image: OpenURI.open_image(parsed_data[:image], 'User-Agent' => Proxy::USER_AGENT)
    )
  end

private

  def parsed_data
    @parsed_data ||= parser.call @entry.id
  rescue InvalidIdError
    nil
  end

  def parser
    "MalParser::Entry::#{@entry.class.base_class.name}".constantize
  end
end
