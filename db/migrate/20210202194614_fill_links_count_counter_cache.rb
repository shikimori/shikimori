class FillLinksCountCounterCache < ActiveRecord::Migration[5.2]
  def change
    scope = Collection.includes(:links)
    size = scope.size

    scope.each_with_index do |collection, index|
      puts "#{index + 1} / #{size}"
      collection.update_column :links_count, collection.links.size
    end
  end
end
