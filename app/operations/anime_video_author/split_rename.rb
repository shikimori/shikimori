# frozen_string_literal: true

class AnimeVideoAuthor::SplitRename < ServiceObjectBase
  pattr_initialize %i[model! anime_id! kind new_name!]

  # updated_at is touched because it is used as cache key animes_videos#index
  def call
    new_author_name = AnimeVideoAuthor.fix_name @new_name
    return if @model.name == new_author_name
    scope = build_scope @model, @anime_id, @kind

    if one_group? scope, @model
      rename_author @model, new_author_name
    elsif new_author_name.present?
      move_videos scope, new_author_name
    else
      change_author @model, @anime_id, nil
    end
  end

private

  def one_group? scope, anime_video_author
    scope.count == anime_video_author.anime_videos.count
  end

  def rename_author anime_video_author, new_author_name
    AnimeVideoAuthor::Rename.call anime_video_author, new_author_name
  end

  def move_videos from_scope, to_author_name
    to_author = AnimeVideoAuthor.find_or_create_by name: to_author_name

    from_scope.update_all(
      anime_video_author_id: to_author.id,
      updated_at: Time.zone.now
    )
  end

  def change_author from_author, anime_id, to_author
    from_author.anime_videos
      .where(anime_id: anime_id)
      .update_all(
        anime_video_author_id: to_author&.id,
        updated_at: Time.zone.now
      )
  end

  def build_scope author, anime_id, kind
    if kind
      author.anime_videos.where(anime_id: anime_id, kind: kind)
    else
      author.anime_videos.where(anime_id: anime_id)
    end
  end
end
