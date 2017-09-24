# frozen_string_literal: true

class AnimeVideoAuthor::SplitRename < ServiceObjectBase
  pattr_initialize %i[model! new_name! anime_id kind]

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
      remove_author scope
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

  def remove_author scope
    scope.update_all(
      anime_video_author_id: nil,
      updated_at: Time.zone.now
    )
  end

  def build_scope author, anime_id, kind
    scope = author.anime_videos.all

    scope.where! anime_id: anime_id if anime_id
    scope.where! kind: kind if kind

    scope
  end
end
