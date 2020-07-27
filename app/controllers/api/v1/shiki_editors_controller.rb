class Api::V1::ShikiEditorsController < Api::V1Controller
  SUPPORTED_TYPES = %i[user anime manga character person user_image comment topic]
  TYPE_INCLUDES = {
    comment: :user,
    topic: %i[user linked]
  }

  def show # rubocop:disable MethodLength
    results = {}

    SUPPORTED_TYPES.each do |kind|
      ids = parse_ids(kind)

      results[kind] = fetch(kind, ids).map do |model|
        case kind
        when :user_image
          serialize_user_image model
        when :user
          serialize_user model
        when :topic, :comment
          serialize_forum_entry model
        else
          serialize_db_entry model
        end
      end
    end

    render json: results
  end

private

  def parse_ids kind
    (params[kind] || '')
      .split(',')
      .uniq
      .map(&:to_i)
      .select { |v| v.present? && v.positive? }
      .take(100)
  end

  def fetch kind, ids
    kind.to_s.classify.constantize
      .includes(TYPE_INCLUDES[kind])
      .where(id: ids)
      .order(:id)
  end

  def serialize_user_image model
    {
      id: model.id,
      url: ImageUrlGenerator.instance.url(model, :original)
      # original_url: model.image.url(:original),
      # preview_url: model.image.url(:preview),
      # width: model.width,
      # height: model.height
    }
  end

  def serialize_user model
    {
      id: model.id,
      nickname: model.nickname,
      avatar: ImageUrlGenerator.instance.url(model, :x32),
      url: profile_url(model)
    }
  end

  def serialize_forum_entry model
    {
      id: model.id,
      author: model.user.nickname,
      url: model.is_a?(Comment) ?
        UrlGenerator.instance.comment_url(model) :
        UrlGenerator.instance.topic_url(model)
    }
  end

  def serialize_db_entry model
    {
      id: model.id,
      text: UsersHelper.localized_name(model, current_user),
      url: UrlGenerator.instance.send(:"#{model.class.name.downcase}_path", model)
    }
  end
end
