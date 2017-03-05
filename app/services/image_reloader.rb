class ImageReloader < ServiceObjectBase
  pattr_initialize :entry

  def call
    return if entry.desynced.include? 'image'

    if parsed_data && parsed_data[:img]
      @entry.update image: open_image(parsed_data[:img], 'User-Agent' => 'Mozilla/4.0 (compatible; ICS)')
    end
  end

private

  def parsed_data
    @parsed_data ||= parser.call @entry.id
  rescue InvalidIdError
  end

  def parser
    "MalParser::Entry::#{@entry.class.name}".constantize
  end
end
