class MalParsers::AnimeAuthorized < MalParser::Entry::Anime
  def type
    'anime'
  end

  def html
    @html ||= make_request url

    if @html.nil? || @html =~ INVALID_ID_REGEXP
      raise RecordNotFound
    else
      @html
    end
  end

  def make_request url
    headers = {
      'Cookie' => MalParsers::Authorization.instance.cookie.join('')
    }

    begin
      open(url, headers).read
    rescue OpenURI::HTTPError => e
      if e.message =~ /404 Not Found/
        raise RecordNotFound
      else
        raise
      end
    end
  end
end
