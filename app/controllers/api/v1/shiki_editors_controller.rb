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

  def serialize_user_image entry
    {
      id: entry.id,
      url: ImageUrlGenerator.instance.url(entry, :original)
      # original_url: entry.image.url(:original),
      # preview_url: entry.image.url(:preview),
      # width: entry.width,
      # height: entry.height
    }
  end

  def serialize_user entry
    {
      id: entry.id,
      nickname: entry.nickname,
      avatar: ImageUrlGenerator.instance.url(entry, :x32),
      url: profile_url(entry)
    }
  end

  def serialize_forum_entry entry
    {
      id: entry.id,
      author: entry.user.nickname,
      url: entry.is_a?(Comment) ?
        UrlGenerator.instance.comment_url(entry) :
        UrlGenerator.instance.topic_url(entru)
    }
  end

  def serialize_db_entry entry
    {
      id: entry.id,
      text: UsersHelper.localized_name(entry, current_user),
      url: UrlGenerator.instance.send(:"#{entry.class.name.downcase}_path", entry)
    }
  end
end
