class VkVideoExtractor
  def initialize url
    @url = url
  end

  def fetch
    OpenStruct.new(
      image_url: parsed_data['jpg'],
      oid: parsed_data['oid'],
      vid: parsed_data['vid'],
      hash2: parsed_data['hash2']
    )
  rescue OpenURI::HTTPError => e
  end

private
  def html
    @html ||= open(@url).read
  end

  def parsed_data
    @parsed_data ||= Rails.cache.fetch @url, expires_in: 2.weeks do
      JSON.parse html.match(/vars = ({.*?});\\nvar/)[1].gsub(/\\/, '')
    end
  end
end
