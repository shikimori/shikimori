class ImageReloader
  def initialize entry
    @entry = entry
  end

  def perform
    if parsed_data && parsed_data[:img]
      @entry.update image: open_image(parsed_data[:img], 'User-Agent' => 'Mozilla/4.0 (compatible; ICS)')
    end
  end

private
  def parsed_data
    @parsed_data ||= parser.fetch_entry_data @entry.id
  end

  def parser
    "#{@entry.class.name}MalParser".constantize.new
  end
end
