class DbEntries::Description
  include ShallowAttributes

  attribute :text, String, allow_nil: true
  attribute :source, String, allow_nil: true

  def value
    if source.present?
      "#{text}[source]#{source}[/source]"
    else
      text.to_s
    end
  end

  class << self
    def from_value value
      text = parse_text(value)
      source = parse_source(value)

      new text: text, source: source
    end

    def from_text_source text, source
      text = text.presence
      source = source.presence

      new text: text, source: source
    end

    private

    def parse_text value
      return if value.blank?
      return value unless value.include? '[source]'

      value[/(.+)(?=\[source\])/m, 1]
    end

    def parse_source value
      return if value.blank?

      value[%r{\[source\](.+)\[/source\]}, 1]
    end
  end
end
