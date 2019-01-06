# fix seauence
# ApplicationRecord.connection.execute("SELECT setval('danbooru_tags_id_seq', (SELECT MAX(id) FROM danbooru_tags))").first
class Tags::ImportDanbooruTags
  LIMIT = 1000
  USER_AGENT = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 '\
    '(KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36'

  KONACHAN_URL = 'https://konachan.com/tag/index.json?order=created_at&limit=0'
  DANBOORU_URL_TEMPLATE = 'https://danbooru.donmai.us/tag/index.json?'\
    '&limit=%<limit>s&order=created_at&page=%<page>s'

  def do_import
    import_page :danbooru, 1, LIMIT
    import_page :danbooru, 2, LIMIT

    import_page :konachan, nil, nil
  end

private

  def import_page imageboard, page, limit
    content = get_page imageboard, page, limit
    found_tags = JSON.parse(content)

    existing_tags = Set.new DanbooruTag.pluck(:name)
    new_tags = found_tags.reject { |v| existing_tags.include?(v['name']) }

    new_tags.each_slice(5000) do |tags|
      batch = build_tags(tags)
      DanbooruTag.import batch
      puts "imported batch of #{batch.size} tags on page #{page}" unless Rails.env == 'test'
    end
  end

  def build_tags tags
    tags.map do |tag|
      DanbooruTag.new(
        name: tag['name'],
        kind: tag['type'],
        ambiguous: tag['ambiguous']
      )
    end
  end

  def get_page imageboard, page, limit
    Faraday.get(imageboard_url(imageboard, page, limit)) do |req|
      req.options[:timeout] = 150
      req.options[:open_timeout] = 150
      req.headers['User-Agent'] = USER_AGENT
    end.body
  end

  def imageboard_url imageboard, page, limit
    case imageboard
      when :konachan
        KONACHAN_URL

      when :danbooru
        format DANBOORU_URL_TEMPLATE, limit: limit, page: page

      else
        raise ArgumentError, "imageboard: #{imageboard}"
    end
  end
end
