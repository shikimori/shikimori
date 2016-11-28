class Elasticsearch::Destroy
  include Sidekiq::Worker
  sidekiq_options queue: :low_priority

  INDEX = Elasticsearch::Config::INDEX

  def perform entry_id, entry_type
    Elasticsearch::Client.instance.delete(
      "#{INDEX}/#{entry_type.downcase}/#{entry_id}"
    )
  end
end
