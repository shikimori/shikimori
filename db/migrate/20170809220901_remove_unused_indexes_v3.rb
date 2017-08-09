class RemoveUnusedIndexesV3 < ActiveRecord::Migration[5.1]
  def change
    remove_index :abuse_requests, name: "index_abuse_requests_on_state_and_kind"
    remove_index :clubs, name: "index_clubs_on_style_id"
    remove_index :styles, name: "index_styles_on_owner_type_and_owner_id"
    remove_index :user_images, name: "index_user_images_on_linked_id_and_linked_type"
    remove_index :name_matches, name: "target_type_phrase_search_index"
  end
end
