class FillClubsElasticsearchIndex < ActiveRecord::Migration[5.0]
  def up
    Elasticsearch::Reindex.call %i[club]
  end
end
