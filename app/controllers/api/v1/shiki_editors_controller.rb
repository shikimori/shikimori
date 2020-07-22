class Api::V1::ShikiEditorsController < Api::V1Controller
  def show
    results = {}

    %w[anime manga character person user_image].each do |kind|
      ids = parse_ids(kind)

      results[kind] = fetch(kind, ids).map do |model|
        if kind == 'user_image'
          serialize_user_image model
        else
          serialize_entry model
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
    kind.classify.constantize
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

  def serialize_entry entry
    {
      id: entry.id,
      text: UsersHelper.localized_name(entry, current_user),
      url: UrlGenerator.instance.send(:"#{entry.class.name.downcase}_path", entry)
    }
  end
end
