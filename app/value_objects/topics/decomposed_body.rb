class Topics::DecomposedBody
  include ShallowAttributes
  prepend ActiveCacher.instance

  attribute :text, String, allow_nil: false
  attribute :source, String, allow_nil: true
  attribute :wall, String, allow_nil: true

  instance_cache :wall_video, :wall_images

  SYSTEM_STUFF_REGEXP = %r{
    (?:
      (?: [\r\n\s]* \[source\](?<source>.+)\[/source\] ) |
      (?<replies> [\r\n\s]* \[replies=[\d,]+\] ) |
      (?<bans> [\r\n\s]* \[ban=\d+\] )
    )*
  }mix

  PARSE_REGEXP = %r{
    \A
    (?<text>[\s\S]*?)
    [\r\n\s]*
    (?<wall> \[wall\].+\[/wall\])?
    #{SYSTEM_STUFF_REGEXP.source}
    \Z
  }mix

  WALL_VIDEO_REGEXP = /\[video = (?<id>\d+) \]/mix
  WALL_IMAGE_REGEXP = /\[(?:poster|image|wall_image) = (?<id>\d+) \]/mix

  def wall_video
    return if wall.blank?

    ids = wall.scan(WALL_VIDEO_REGEXP).map { |v| v[0].to_i }
    Video.find_by(id: ids)
  end

  def wall_images
    return [] if wall.blank?

    ids = wall.scan(WALL_IMAGE_REGEXP).map { |v| v[0].to_i }
    UserImage.where(id: ids).sort_by { |v| ids.index v.id }
  end

  class << self
    def from_value value
      matches = (value || '').match PARSE_REGEXP

      new(
        text: matches[:text] + (matches[:replies] || '') + (matches[:bans] || ''),
        wall: matches[:wall],
        source: matches[:source]
      )
    end
  end
end
