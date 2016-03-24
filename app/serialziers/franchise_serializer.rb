class FranchiseSerializer < ActiveModel::Serializer
  attributes :links, :nodes

  def default_url_options
    {
      host: Draper::ViewContext.current.request.host,
      protocol: false
    }
  end

  def links
    all_links.map do |link|
      {
        source: all_entries.index {|v| v.id == link.source_id },
        target: all_entries.index {|v| v.id == (object.anime? ? link.anime_id : link.manga_id) },
        weight: all_links.count {|v| v.source_id == link.source_id },
        relation: link.relation.downcase.gsub(/[ -]/, '_')
      }
    end.select {|v| v[:source] && v[:target] }
  end

  def nodes
    all_entries.map do |entry|
      {
        id: entry.id,
        date: (entry.aired_on || Time.zone.now).to_time.to_i,
        name: UsersHelper.localized_name(entry, scope),
        image_url: ImageUrlGenerator.instance.url(entry, :x96),
        url: url_for(entry),
        year: entry.aired_on.try(:year),
        kind: entry.kind_text,
        weight: all_links.count {|v| v.source_id == entry.id },
      }
    end
  end

private

  def query
    @query ||= ChronologyQuery.new object.decorated? ? object.object : object
  end

  def all_entries
    @entries ||= query.fetch#.select {|v| [5081,15689].include?(v.id) }
  end

  def all_links
    @links ||= query.links#.select {|v| [5081,15689].include?(v.source_id) && [5081,15689].include?(v.anime_id) }
  end
end
