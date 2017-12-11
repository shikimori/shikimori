class Elasticsearch::Destroy
  include Sidekiq::Worker
  sidekiq_options queue: :low_priority

  INDEX = Elasticsearch::Config::INDEX

  def perform entry_id, entry_type
    type = entry_type.downcase.pluralize

    Elasticsearch::ClientOld.instance.delete(
      "#{INDEX}_#{type}/#{type}/#{entry_id}"
    )
  end
end
