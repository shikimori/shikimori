class DanbooruController < ShikimoriController
  respond_to :json, only: %i[autocomplete yandere]

  USER_AGENT_WITH_SSL = {
    'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3) '\
      'AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.153 Safari/537.36',
    ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE
  }
  EXCEPTIONS = Network::FaradayGet::NET_ERRORS

  VALID_URL = %r{https?://(?:yande.re|konachan.com|safebooru.org|danbooru.donmai.us)/}

  def autocomplete
    @collection = DanbooruTagsQuery.new(params[:search]).complete
  end

  def yandere
    Retryable.retryable tries: 2, on: EXCEPTIONS, sleep: 1 do
      url = Base64.decode64 URI.decode(params[:url])
      raise Forbidden, url unless url.match? VALID_URL

      json = PgCache.fetch "yandere_#{url}", expires_in: 1.weeks do
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

private

  def parse_safeboory xml
    Nokogiri::XML(xml).css('posts post').map(&:to_h)
  end
end
