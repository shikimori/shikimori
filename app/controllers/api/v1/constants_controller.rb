class Api::V1::ConstantsController < Api::V1::ApiController
  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, '/constants/anime'
  def anime
    render json: {
      kind: Anime.kind.values,
      status: Anime.status.values
    }
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, '/constants/manga'
  def manga
    render json: {
      kind: Manga.kind.values,
      status: Manga.status.values
    }
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, '/constants/user_rate'
  def user_rate
    render json: {
      status: UserRate.statuses.keys
    }
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, '/constants/club'
  def club
    render json: {
      join_policy: Club.join_policies.keys,
      comment_policy: Club.comment_policies.keys
    }
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
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
