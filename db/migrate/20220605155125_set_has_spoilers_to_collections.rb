class SetHasSpoilersToCollections < ActiveRecord::Migration[6.1]
  def up
    Collection.where("name ILIKE '%[СПОЙЛЕРЫ]%'").update_all(has_spoilers: true)
  end

  def down
    Collection.where("name ILIKE '%[СПОЙЛЕРЫ]%'").update_all(has_spoilers: false)
  end
end