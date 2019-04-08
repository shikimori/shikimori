class Coub::Results
  include ShallowAttributes

  attribute :coubs, Array, of: Coub::Entry
  attribute :iterator, String

  def checksum
    Encoder.instance.checksum iterator
  end
end
