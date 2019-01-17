class CoubsController < ShikimoriController
  def fetch
    # Retryable.retryable tries: 2, on: EXCEPTIONS, sleep: 1 do
    #   url = Base64.decode64 URI.decode(params[:url])
    #   raise Forbidden, url unless url.match? VALID_URL

    #   json = PgCache.fetch pg_cache_key, expires_in: EXPIRES_IN do
    #     content = OpenURI.open_uri(url, USER_AGENT_WITH_SSL).read

    #     if url.match? 'safebooru.org'
    #       parse_safeboory content
    #     else
    #       content
    #     end
    #   end

    #   render json: json
    # end
  end

  def autocomplete
    @collection = CoubTagsQuery.new(params[:search]).complete
  end
end
