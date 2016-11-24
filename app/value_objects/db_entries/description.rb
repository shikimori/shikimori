class DbEntries::Description < Dry::Struct
  attribute :text, Types::Strict::String.optional
  attribute :source, Types::Strict::String.optional

  def self.from_description description
    text = parse_text(description)
    source = parse_source(description)
    self.new text: text, source: source
  end

  def self.from_text_source text, source
    text = text.presence
    source = source.presence
    self.new text: text, source: source
  end

  def description
    "#{text}[source]#{source}[/source]"
  end

  private_class_method

  def self.parse_text description
    return unless description.present?
    return description if description !~ /\[source\]/
    description[/(.+)(?=\[source\])/, 1]
  end

  def self.parse_source description
    return unless description.present?
    description[%r{\[source\](.+)\[/source\]}, 1]
  end
end
