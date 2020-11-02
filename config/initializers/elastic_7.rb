# config/initializers/elastic_7.rb
# https://www.elastic.co/guide/en/elasticsearch/reference/current/breaking-changes-7.0.html#hits-total-now-object-search-response
# https://www.elastic.co/blog/moving-from-types-to-typeless-apis-in-elasticsearch-7-0
# https://www.elastic.co/guide/en/elasticsearch/reference/current/removal-of-types.html#_schedule_for_removal_of_mapping_types

Elasticsearch::Transport::Client.prepend Module.new {
  def search(arguments = {})
    arguments[:rest_total_hits_as_int] = true
    super arguments
  end
}
Elasticsearch::API::Indices::IndicesClient.prepend Module.new {
  def create(arguments = {})
    arguments[:include_type_name] = true
    super arguments
  end

  def put_mapping(arguments = {})
    arguments[:include_type_name] = true
    super arguments
  end
}
