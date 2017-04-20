class MakeCollectionsForumInvisible < ActiveRecord::Migration[5.0]
  def up
    Forum.where(id: Forum::COLLECTION_ID).update_all is_visible: false
  end

  def down
    Forum.where(id: Forum::COLLECTION_ID).update_all is_visible: true
  end
end
