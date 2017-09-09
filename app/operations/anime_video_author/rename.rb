# frozen_string_literal: true

class AnimeVideoAuthor::Rename < ServiceObjectBase
  pattr_initialize :model, :new_name

  # updated_at is touched because it is used as cache key animes_videos#index
  def call
    @model.name = @new_name
    return unless @model.changed?

    unless rename @model, @model.name
      move_videos @model, @model.name
      @model.destroy!
    end
  end

private

  def rename model, new_name
    if model.update name: new_name
      model.anime_videos.update_all updated_at: Time.zone.now
      true

    else
      false
    end
  end

  def move_videos from_author, to_author_name
    to_author = AnimeVideoAuthor.find_by name: to_author_name

    from_author.anime_videos.update_all(
      anime_video_author_id: to_author&.id,
      updated_at: Time.zone.now
    )
  end
end
