class ChangeUrlColumnsStringLimitsAndAddNotNullsV1 < ActiveRecord::Migration[5.2]
  def up
    Video.where(image_url: nil).destroy_all
    UserToken.where(user_id: nil).destroy_all

    change_column :critiques, :target_id, :integer, null: false
    change_column :critiques, :target_type, :string, null: false
    change_column :critiques, :user_id, :integer, null: false
    change_column :critiques, :text, :text, null: false
    change_column :critiques, :source, :string
    change_column :critiques, :moderation_state, :string, null: false

    change_column :publishers, :name, :string, null: false

    change_column :studios, :name, :string, null: false
    change_column :studios, :website, :string
    change_column :studios, :japanese, :string
    change_column :studios, :ani_db_name, :string
    change_column :studios, :short_name, :string

    change_column :topics, :user_id, :integer, null: false
    change_column :topics, :forum_id, :integer, null: false
    change_column :topics, :user_id, :integer, null: false
    change_column :topics, :user_id, :integer, null: false

    change_column :user_histories, :user_id, :integer, null: false
    change_column :user_images, :user_id, :integer, null: false
    change_column :user_preferences, :user_id, :integer, null: false

    change_column :user_rates, :user_id, :integer, null: false
    change_column :user_rates, :target_id, :integer, null: false
    change_column :user_rates, :target_type, :string, null: false

    change_column :user_tokens, :user_id, :integer, null: false
    change_column :user_tokens, :provider, :string, null: false
    change_column :user_tokens, :uid, :string, null: false
    change_column :user_tokens, :token, :string
    change_column :user_tokens, :secret, :string

    change_column :users, :email, :string, null: false
    change_column :users, :website, :string

    change_column :versions, :item_type, :string, null: false
    change_column :versions, :item_id, :integer, null: false
    change_column :versions, :state, :string, null: false

    change_column :videos, :name, :string
    change_column :videos, :url, :string, null: false
    change_column :videos, :image_url, :string, null: false
    change_column :videos, :player_url, :string, null: false
    change_column :videos, :hosting, :string, null: false
    change_column :videos, :kind, :string, null: false

    change_column :webm_videos, :url, :string, null: false
  end

  def down
    change_column :critiques, :target_id, :integer
    change_column :critiques, :target_type, :string
    change_column :critiques, :user_id, :integer
    change_column :critiques, :text, :text
    change_column :critiques, :source, :string, limit: 255
    change_column :critiques, :moderation_state, :string,  limit: 255

    change_column :publishers, :name, :string, limit: 255

    change_column :studios, :name, :string, limit: 255
    change_column :studios, :website, :string, limit: 255
    change_column :studios, :japanese, :string, limit: 255
    change_column :studios, :ani_db_name, :string, limit: 255
    change_column :studios, :short_name, :string, limit: 255

    change_column :topics, :user_id, :integer
    change_column :topics, :forum_id, :integer

    change_column :user_histories, :user_id, :integer
    change_column :user_images, :user_id, :integer
    change_column :user_preferences, :user_id, :integer

    change_column :user_rates, :user_id, :integer
    change_column :user_rates, :target_id, :integer
    change_column :user_rates, :target_type, :string, limit: 255

    change_column :user_tokens, :user_id, :integer
    change_column :user_tokens, :provider, :string, limit: 255
    change_column :user_tokens, :uid, :string, limit: 255
    change_column :user_tokens, :token, :string, limit: 255
    change_column :user_tokens, :secret, :string, limit: 255

    change_column :users, :email, :string, limit: 255
    change_column :users, :website, :string, limit: 1024

    change_column :versions, :item_type, :string, limit: 255
    change_column :versions, :item_id, :integer
    change_column :versions, :state, :string, limit: 255

    change_column :videos, :name, :string, limit: 255
    change_column :videos, :url, :string, limit: 255
    change_column :videos, :image_url, :string, limit: 1024
    change_column :videos, :player_url, :string, limit: 1024
    change_column :videos, :hosting, :string, limit: 255
    change_column :videos, :kind, :string, limit: 255

    change_column :webm_videos, :url, :string, null: false, limit: 1024
  end
end
