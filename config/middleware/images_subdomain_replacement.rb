# app/middleware/text_replacement_middleware.rb
class ImagesSubdomainReplacement
  def initialize(app)
    @app = app
  end

  def call(env)
    # Call the upstream middleware stack
    status, headers, response = @app.call(env)

    if env['HTTP_CF_IPCOUNTRY'] == 'UA'
      # Only modify HTML and JSON responses
      if headers['Content-Type']&.include?('html') || headers['Content-Type']&.include?('json')
        body = ''

        # Collect the response body
        response.each { |part| body << part }

        # Perform the text replacement
        body = body.gsub('moe.shikimori.one', 'desu.shikimori.one')

        # Update the Content-Length header
        headers['Content-Length'] = body.bytesize.to_s

        # Replace the original response with the modified body
        response = [body]
      end
    end

    # Return the (possibly modified) response
    [status, headers, response]
  end
end

