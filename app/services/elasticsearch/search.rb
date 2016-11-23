# Optimizing Elasticsearch (part 1): Rescoring queries with multi-type fields
# https://tryolabs.com/blog/2015/03/04/optimizing-elasticsearch-rescoring-queries-with-multi-type-fields/
class Elasticsearch::Search
  method_object [:phrase, :type, :limit]

  INDEX = :names
  EXPIRES_IN = 1.hour

  def call
    Rails.cache.fetch(cache_key, expires_in: EXPIRES_IN) { parse api_call }
  end

private

  def api_call
    client.get "#{INDEX}/#{@type}/_search?from=0&size=#{@limit}",
      query: {
        bool: {
          should: [
            { match: { names: @phrase } },
            # { match: { name: @phrase } },
            # { match: { english: @phrase } },
            # { match: { russian: @phrase } },
            # { match: { japanese: @phrase } }
          ]
        }
      }
  end

  def parse api_results
    api_results['hits']['hits']#.select do |hit|
      # hit['_score'] >= api_results['hits']['max_score'] / 2.5
    # end
  end

  def cache_key
    [
      @type,
      @phrase,
      Elasticsearch::Config.instance[:version]
    ]
  end

  def client
    @client ||= Elasticsearch::Client.new
  end
end
