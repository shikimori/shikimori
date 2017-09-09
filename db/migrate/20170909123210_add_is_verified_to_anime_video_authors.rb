class AddIsVerifiedToAnimeVideoAuthors < ActiveRecord::Migration[5.1]
  def change
    add_column :anime_video_authors, :is_verified, :boolean,
      null: false,
      default: false
  end
end
