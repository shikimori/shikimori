# frozen_string_literal: true

class AnimeVideoAuthor::Rename < ServiceObjectBase
  pattr_initialize :model, :new_name

  def call
    return if @model.update name: @new_name

    new_author = AnimeVideoAuthor.find_by name: @new_name

    @model.anime_videos.update_all anime_video_author_id: new_author
    @model.destroy!
  end
end
