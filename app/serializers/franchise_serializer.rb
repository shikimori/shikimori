class FranchiseSerializer < ActiveModel::Serializer
  attributes :links, :nodes, :current_id

  def default_url_options
    {
      host: Draper::ViewContext.current.request.host,
      protocol: false
    }
  end

  def current_id
    object.id
  end

  def links # rubocop:disable AbcSize, MethodLength
    all_links
      .map do |link|
        source_index = all_entries.index { |v| v.id == link.source_id }
        target_index = all_entries.index do |v|
          v.id == (object.anime? ? link.anime_id : link.manga_id)
        end
        next unless source_index && target_index

        {
          id: link.id,
          source_id: link.source.id,
          target_id: object.anime? ? link.anime_id : link.manga_id,
          source: source_index,
          target: target_index,
          weight: all_links.count { |v| v.source_id == link.source_id },
          relation: link.relation.downcase.gsub(/[ -]/, '_')
        }
      end
    .compact
  end

  def nodes # rubocop:disable AbcSize
    all_entries.map do |entry|
      {
        id: entry.id,
        date: (entry.aired_on.date || Time.zone.now).to_time.to_i,
        name: UsersHelper.localized_name(entry, scope.current_user),
        image_url: ImageUrlGenerator.instance.cdn_image_url(entry, :x96),
        url: view_context.url_for(entry),
        year: entry.aired_on.year,
        kind: entry.kind_text,
        weight: all_links.count { |v| v.source_id == entry.id }
      }
    end
  end

private

  def query
    @query ||= Animes::ChronologyQuery.new(
      object.decorated? ? object.object : object
    )
  end

  def all_entries
    @all_entries ||= query.fetch
    # .select {|v| [5081,15689].include?(v.id) }
  end

  def all_links
    @all_links ||= query.links
    # .select {|v| [5081,15689].include?(v.source_id) && [5081,15689].include?(v.anime_id) }
  end
end
