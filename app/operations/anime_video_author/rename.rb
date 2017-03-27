# frozen_string_literal: true

class AnimeVideoAuthor::Rename < ServiceObjectBase
  pattr_initialize :model, :new_name

  # rubocop:disable MethodLength
  # updated_at is touched because it is used as cache key animes_videos#index
  def call
    @model.name = @new_name
    return unless @model.changed?

    if @model.update name: @new_name
      @model.anime_videos.update_all updated_at: Time.zone.now
      return
    end

    new_author = AnimeVideoAuthor.find_by name: @new_name

    @model.anime_videos.update_all(
      anime_video_author_id: new_author&.id,
      updated_at: Time.zone.now
    )
    @model.destroy!
  end
  # rubocop:enable MethodLength
end
