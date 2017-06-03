class FillCollectionsElasticsearchIndex < ActiveRecord::Migration[5.0]
  def up
    Elasticsearch::Reindex.call %i[collection]
  end
end
