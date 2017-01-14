class DbEntries::Description < Dry::Struct
  attribute :text, Types::Strict::String.optional
  attribute :source, Types::Strict::String.optional

  def self.from_value value
    text = parse_text(value)
    source = parse_source(value)
    self.new text: text, source: source
  end

  def self.from_text_source text, source
    text = text.presence
    source = source.presence
    self.new text: text, source: source
  end

  def value
    if source.present?
      "#{text}[source]#{source}[/source]"
    else
      "#{text}"
    end
  end

  private_class_method

  def self.parse_text value
    return unless value.present?
    return value if value !~ /\[source\]/
    value[/(.+)(?=\[source\])/m, 1]
  end

  def self.parse_source value
    return unless value.present?
    value[%r{\[source\](.+)\[/source\]}, 1]
  end
end
