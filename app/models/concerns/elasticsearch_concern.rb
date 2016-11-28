module ElasticsearchConcern
  extend ActiveSupport::Concern

  included do
    after_create :post_elastic
    after_update :put_elastic
    after_destroy :delete_elastic
  end

private

  def post_elastic
    Elasticsearch::Client.instance.post(
      "#{Elasticsearch::Config::INDEX}/#{self.class.name.downcase}/#{id}",
      "Elasticsearch::Data::#{self.class.name}".constantize.call(self)
    )
  end

  def put_elastic
    elastic_changes = "Elasticsearch::Data::#{self.class.name}::ALL_FIELDS"
      .constantize
      .any? { |field| changes[field] }

    post_elastic if elastic_changes
  end

  def delete_elastic
    Elasticsearch::Client.instance.delete(
      "#{Elasticsearch::Config::INDEX}/#{self.class.name.downcase}/#{id}"
    )
  end
end
