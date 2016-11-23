class Elasticsearch::Client
  ELASTIC_URL = 'http://localhost:9200'

  def post path, data
    request :post, path, data
  end

  def put path, data
    request :put, path, data
  end

  def get path, data
    request :get, path, data
  end

  def delete path
    url = "#{ELASTIC_URL}/#{path}"

    NamedLogger.elasticserach_api.info "DELETE #{url}"
    process faraday.delete(url)

  rescue ElasticsearchError => e
    raise unless e.status == 404
  end

private

  def request method, path, data
    url = "#{ELASTIC_URL}/#{path}"

    NamedLogger.elasticserach_api.info <<-LOG.strip
      #{method.upcase} #{url}\n#{data.to_json}
    LOG
    response = faraday
      .send(method, "#{ELASTIC_URL}/#{path}") { |r| r.body = data.to_json }

    process response
  end

  def process response
    if response.status != 200 && response.status != 201
      raise ElasticsearchError.new(response.status, response.body)
    else
      response.body
    end
  end

  def faraday
    Faraday.new do |builder|
      builder.adapter :net_http
      builder.response :json
    end
  end
end
