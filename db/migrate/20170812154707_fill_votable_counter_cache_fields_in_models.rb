class FillVotableCounterCacheFieldsInModels < ActiveRecord::Migration[5.1]
  def up
    [Review, CosplayGallery, Collection].each do |klass|
      puts "migrating #{klass.table_name}"

      klass.find_each do |model|
        model.update(
          cached_votes_up: model.votes_for.up.size,
          cached_votes_down: model.votes_for.down.size,
        )
      end
    end
  end
end
