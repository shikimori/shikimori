class FillLinksCountCounterCache < ActiveRecord::Migration[5.2]
  def change
    commit_db_transaction
    scope = Collection.all
    size = scope.size

    scope.each_with_index do |collection, index|
      puts "#{index + 1} / #{size}"

      Collection.reset_counters collection.id, :links_count
    end
  end
end
