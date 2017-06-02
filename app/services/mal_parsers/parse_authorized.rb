module MalParsers::ParseAuthorized
  def html
    @html ||= make_request(url)&.fix_encoding

    if !@html || @html =~ MalParser::Entry::Base::INVALID_ID_REGEXP
      raise InvalidIdError, url
    else
      @html
    end
  end

  # rubocop:disable MethodLength
  def make_request url
    headers = {
      'Cookie' => MalParsers::Authorization.instance.cookie.join
    }

    begin
      open(url, headers).read
    rescue OpenURI::HTTPError => e
      if e.message =~ /404 Not Found/
        raise InvalidIdError, url
      else
        raise
      end
    end
  end
  # rubocop:enable MethodLength
end
