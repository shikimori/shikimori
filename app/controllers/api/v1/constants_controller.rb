class Api::V1::ConstantsController < Api::V1Controller
  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :GET, '/constants/anime'
  def anime
    render json: {
      kind: Anime.kind.values,
      status: Anime.status.values
    }
  end

  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :GET, '/constants/manga'
  def manga
    render json: {
      kind: Manga.kind.values,
      status: Manga.status.values
    }
  end

  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :GET, '/constants/user_rate'
  def user_rate
    render json: {
      status: UserRate.statuses.keys
    }
  end

  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :GET, '/constants/club'
  def club
    render json: {
      join_policy: Club.join_policy.values,
      comment_policy: Club.comment_policy.values,
      image_upload_policy: Club.image_upload_policy.values
    }
  end

  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :GET, '/constants/smileys'
  def smileys
    collection = CommentHelper.class_variable_get(:@@smiley_groups).flatten.map do |smiley|
      {
        bbcode: smiley,
        path: "#{CommentHelper.class_variable_get(:@@smileys_path)}#{smiley}.gif",
      }
    end

    render json: collection
  end
end
