# module MalParsers::ParseAuthorized
#   def html
#     @html ||= make_request(url)&.fix_encoding
#
#     if !@html || @html =~ MalParser::Entry::Base::INVALID_ID_REGEXP
#       raise InvalidIdError, url
#     else
#       @html
#     end
#   end
#
#   def make_request url
#     OpenURI.open_uri(url, headers).read
#   rescue OpenURI::HTTPError => e
#     if /404 Not Found/.match?(e.message)
#       raise InvalidIdError, url
#     else
#       raise
#     end
#   end
#
#   def headers
#     {
#       'Cookie' => MalParsers::Authorization.instance.cookie.join,
#       **Proxy.prepaid_proxy
#     }
#   end
# end
