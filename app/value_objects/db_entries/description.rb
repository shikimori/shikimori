class DbEntries::Description < Dry::Struct
  attribute :value, Types::Strict::String.optional

  def html
    value[/(.*)(?=\[source\])/, 1]
  end

  def source
    value[/\[source\](.*)\[\/source\]/, 1]
  end
end
