module ElasticsearchConcern
  extend ActiveSupport::Concern

  included do
    after_create :post_elastic
    after_update :put_elastic
    after_destroy :delete_elastic
  end

private

  def post_elastic
    Elasticsearch::Create.perform_async id, self.class.name
  end

  def put_elastic
    elastic_changes = "Elasticsearch::Data::#{self.class.name}::ALL_FIELDS"
      .constantize
      .any? { |field| changes[field] }

    Elasticsearch::Update.perform_async id, self.class.name if elastic_changes
  end

  def delete_elastic
    Elasticsearch::Destroy.perform_async id, self.class.name
  end
end
