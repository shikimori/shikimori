module Metrika
  module Helpers
    module Request
    protected
      def get(path, params = {}, options = {})
        begin
          response = self.token.get(path+'.json', DEFAULT_OPTIONS.merge(:params => params).merge(options))
        rescue OAuth2::Error => e
          self.process_oauth2_errors(e.response.status, e.message, path, params)
        end

        Yajl::Parser.parse(response.body)
      end
    end
  end
end
