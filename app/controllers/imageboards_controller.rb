class ImageboardsController < ShikimoriController
  USER_AGENT_WITH_SSL = {
    'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3) '\
      'AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.153 Safari/537.36',
    ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE
  }
  EXCEPTIONS = Network::FaradayGet::NET_ERRORS

  VALID_URL = %r{https?://(?:yande.re|konachan.com|safebooru.org|danbooru.donmai.us)/}
  EXPIRES_IN = 4.months

  # TODO: extract into service object similar to Coubs::Request
  def fetch
    Retryable.retryable tries: 2, on: EXCEPTIONS, sleep: 1 do
      url = Base64.decode64 URI.decode(params[:url])
      raise Forbidden, url unless url.match? VALID_URL

      json = PgCache.fetch pg_cache_key, expires_in: EXPIRES_IN do
        content = OpenURI.open_uri(url, USER_AGENT_WITH_SSL).read

        if url.match? 'safebooru.org'
          parse_safeboory content
        else
          content
        end
      end

      render json: json
    end
  end

  def autocomplete
    @collection = DanbooruTagsQuery.new(params[:search]).complete
  end

  def self.pg_cache_key tag:, imageboard:, page:
    [tag, imageboard, page].join('|')
  end

private

  def parse_safeboory xml
    Nokogiri::XML(xml).css('posts post').map(&:to_h)
  end

  def pg_cache_key
    self.class.pg_cache_key(
      tag: params[:tag],
      imageboard: params[:imageboard],
      page: params[:page]
    )
  end
end
