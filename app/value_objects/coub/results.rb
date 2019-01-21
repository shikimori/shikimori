class Coub::Results < Dry::Struct
  attribute :coubs, Types::Array.of(Coub::Entry)
  attribute :iterator, Types::String

  def encrypted_iterator
    Encoder.instance.encode iterator
  end
end
