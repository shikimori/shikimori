class DbEntries::Description < Dry::Struct
  attribute :value, Types::Strict::String.optional

  def text
    return unless value.present?
    return value if value !~ /\[source\]/
    value[/(.*)(?=\[source\])/, 1]
  end

  def source
    return unless value.present?
    value[%r{\[source\](.*)\[/source\]}, 1]
  end
end
