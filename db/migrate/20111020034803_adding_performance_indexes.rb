class AddingPerformanceIndexes < ActiveRecord::Migration
  def self.up
    add_index :person_roles, [:role, :anime_id, :character_id], :name => :i_person_role_role_anime_id
    add_index :person_roles, [:role, :manga_id, :character_id], :name => :i_person_role_role_manga_id

    add_index :person_roles, :anime_id
    add_index :person_roles, :manga_id
    add_index :person_roles, :character_id
    add_index :person_roles, :person_id

    add_index :user_changes, [:status, :model, :item_id], :name => :i_user_changes

    add_index :user_rates, [:target_id, :target_type], :name => :i_target

    add_index :attached_images, [:owner_id, :owner_type], :name => :i_owner

    add_index :similar_animes, :src_id
    add_index :similar_mangas, :src_id

    add_index :animes_genres, :anime_id
    add_index :animes_studios, :anime_id

    add_index :genres_mangas, :manga_id
    add_index :mangas_publishers, :manga_id

    add_index :cosplay_images, [:cosplay_gallery_id, :deleted], :name => :i_cosplay_images_gallery_id_deleted
    add_index :cosplay_gallery_links, [:cosplay_gallery_id, :linked_type], :name => :i_cosplay_gallery_id_linked_type

    add_index :entry_views, [:entry_id, :user_id], :name => :i_entry_views_entry_id_user_id
    add_index :entries, [:type, :linked_id, :linked_type], :name => :i_entries_type_linked_type_linked_id
    add_index :entries, [:type, :comment_threads_count, :updated_at], :name => :i_entries_type_comments_count_updated_at
    add_index :entries, [:type, :user_id], :name => :i_entries_type_user_id

    add_index :subscriptions, :user_id
    add_index :favourites, :user_id

    add_index :user_changes, :status

    add_index :messages, [:dst_type, :dst_id, :kind, :read], :name => :messages_for_profile
  end

  def self.down
    remove_index :person_roles, :name => :i_person_role_role_anime_id
    remove_index :person_roles, :name => :i_person_role_role_manga_id

    remove_index :person_roles, :anime_id
    remove_index :person_roles, :manga_id
    remove_index :person_roles, :character_id
    remove_index :person_roles, :person_id

    remove_index :user_changes, :name => :i_user_changes

    remove_index :user_rates, :name => :i_target

    remove_index :attached_images, :name => :i_owner

    remove_index :similar_animes, :src_id
    remove_index :similar_mangas, :src_id

    remove_index :animes_genres, :anime_id
    remove_index :animes_studios, :anime_id

    remove_index :genres_mangas, :manga_id
    remove_index :mangas_publishers, :manga_id

    remove_index :cosplay_images, :name => :i_cosplay_images_gallery_id_deleted
    remove_index :cosplay_gallery_links, :name => :i_cosplay_gallery_id_linked_type

    remove_index :entry_views, :name => :i_entry_views_entry_id_user_id
    remove_index :entries, :name => :i_entries_type_linked_type_linked_id
    remove_index :entries, :name => :i_entries_type_comments_count_updated_at
    remove_index :entries, :name => :i_entries_type_user_id

    remove_index :subscriptions, :user_id
    remove_index :favourites, :user_id

    remove_index :user_changes, :status

    remove_index :messages, :name => :messages_for_profile
  end
end
