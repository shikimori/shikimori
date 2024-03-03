# no need to keep this code since imageboards feature is disabled anyway
class ImageboardsController < ShikimoriController
  # USER_AGENT = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/537.36 ' \
  #   '(KHTML, like Gecko) Chrome/84.0.4147.135 Safari/537.36'
  # EXCEPTIONS = Network::FaradayGet::NET_ERRORS
  #
  # VALID_URL = %r{\Ahttps?://(?:yande.re|konachan.com|safebooru.org|danbooru.donmai.us)/}
  EXPIRES_IN = 4.months
  #
  # # TODO: extract into service object similar to Coubs::Request
  # def index
  #   Retryable.retryable tries: 2, on: EXCEPTIONS, sleep: 1 do
  #     url = Base64.decode64 Addressable::URI.unencode(params[:url])
  #     # # XSS: do not pass user input (url) as CanCan::AccessDenied argument since it leads to XSS
  #     # Example: https://shikimori.one/imageboards/PCFET0NUWVBFIGh0bWw+PGh0bWwgbGFuZz0iZW4iPjxoZWFkPjxzY3JpcHQ+YWxlcnQoJ2hhY2tlZCcpPC9zY3JpcHQ+PC9oZWFkPjxib2R5PjwvYm9keT48L2h0bWw+
  #     # <!DOCTYPE html><html lang="en"><head><script>alert('hacked')</script></head><body></body></html>
  #     raise CanCan::AccessDenied unless url.match? VALID_URL
  #
  #     json = PgCache.fetch pg_cache_key, expires_in: EXPIRES_IN do
  #       NamedLogger.download_imageboard.info "#{url} start"
  #       content = OpenURI.open_uri(url, open_uri_options).read
  #       NamedLogger.download_imageboard.info "#{url} end"
  #
  #       if url.match? 'safebooru.org'
  #         parse_safeboory content
  #       else
  #         parse_json content
  #       end
  #     end
  #
  #     render json: json
  #   end
  # end
  #
  # def autocomplete
  #   cache_key = [:autocomplete, :imageboard_tags, params[:search]]
  #
  #   @collection =
  #     Rails.cache.fetch cache_key, expires_in: 1.month do
  #       DanbooruTagsQuery.new(params[:search]).complete
  #     end
  # end

  def self.pg_cache_key tag:, imageboard:, page:
    [tag, imageboard, page].join('|')
  end

# private

  # def open_uri_options
  #   {
  #     'User-Agent' => USER_AGENT,
  #     ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE,
  #     proxy_http_basic_authentication: http_proxy
  #   }.compact
  # end
  #
  # def http_proxy
  #   return nil unless Rails.env.development?
  #
  #   [
  #     Rails.application.secrets.proxy[:url],
  #     Rails.application.secrets.proxy[:login],
  #     Rails.application.secrets.proxy[:password]
  #   ]
  # end
  #
  # def parse_safeboory xml
  #   Nokogiri::XML(xml).css('posts post').map(&:to_h)
  # end
  #
  # def parse_json json
  #   JSON.parse json
  # rescue JSON::ParserError
  #   []
  # end
  #
  # def pg_cache_key
  #   self.class.pg_cache_key(
  #     tag: params[:tag],
  #     imageboard: params[:imageboard],
  #     page: params[:page]
  #   )
  # end
end
