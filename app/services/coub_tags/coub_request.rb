class CoubTags::CoubRequest
  method_object :tag, :page

  COUB_TEMPLATE = 'https://coub.com/api/v2/timeline/tag/%<tag>s?page=%<page>i'
  EMBED_TEMPLATE = 'https://coub.com/embed/%<permalink>s'
  PER_PAGE = 10

  EXPIRES_IN = 4.months
  EXCEPTIONS = Network::FaradayGet::NET_ERRORS

  def call
    Retryable.retryable tries: 2, on: EXCEPTIONS, sleep: 1 do
      PgCache.fetch pg_cache_key, expires_in: EXPIRES_IN do
        convert verify(parse(fetch))
      end
    end
  rescue *EXCEPTIONS
    nil
  end

  def self.pg_cache_key tag, page
    [tag, page].join('|')
  end

private

  def pg_cache_key
    self.class.pg_cache_key @tag, @page
  end

  def convert data
    data[:coubs].map do |entry|
      Coub::Entry.new(
        image_url: entry[:picture],
        player_url: format(EMBED_TEMPLATE, permalink: entry[:permalink]),
        categories: entry[:categories].map { |v| v[:permalink] },
        tags: entry[:tags].map { |v| URI.unescape v[:value] }
      )
    end
  end

  def verify data
    if data[:per_page] != PER_PAGE
      raise "invalid response for tag `#{@tag}`"
    end

    data
  end

  def parse response
    JSON.parse response, symbolize_names: true
  end

  def fetch
    OpenURI.open_uri(coub_url, 'User-Agent' => 'shikimori.org').read
  end

  def coub_url
    format COUB_TEMPLATE, tag: URI.escape(@tag), page: @page
  end
end
