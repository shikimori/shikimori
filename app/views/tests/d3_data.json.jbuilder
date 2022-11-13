json.nodes(@entries.map { |entry|
  {
    id: entry.id,
    date: (entry.aired_on.date || Time.zone.now).to_time.to_i,
    name: localized_name(entry),
    image_url: cdn_image_url(entry, :x96),
    url: url_for(entry),
    weight: @links.count {|v| v.source_id == entry.id }
  }
})

json.links(@links.map { |link|
  {
    source: @entries.index {|v| v.id == link.source_id },
    target: @entries.index {|v| v.id == link.anime_id },
    weight: @links.count {|v| v.source_id == link.source_id },
    relation: link.relation.downcase.gsub(/[ -]/, '_')
  }
})
