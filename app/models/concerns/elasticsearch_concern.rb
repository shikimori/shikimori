module ElasticsearchConcern
  extend ActiveSupport::Concern

  included do
    after_create :post_elastic
    after_update :put_elastic
    after_destroy :delete_elastic
  end

private

  def post_elastic
    Elasticsearch::Create.perform_async id, class_name
  end

  def put_elastic
    elastic_changes = data_fields.any? { |field| saved_changes[field] }
    Elasticsearch::Update.perform_async id, class_name if elastic_changes
  end

  def delete_elastic
    Elasticsearch::Destroy.perform_async id, class_name
  end

  def data_fields
    "Elasticsearch::Data::#{class_name}::TRACK_CHANGES_FIELDS".constantize
  end

  def class_name
    self.class.base_class.name
  end
end
