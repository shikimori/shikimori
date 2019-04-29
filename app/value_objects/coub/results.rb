class Coub::Results
  include ShallowAttributes

  attribute :coubs, Array, of: Coub::Entry
  attribute :iterator, String, allow_nil: true

  def checksum
    Encoder.instance.checksum iterator
  end
end
