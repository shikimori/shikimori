class TransformedCollection < SimpleDelegator
  def initialize collection, transformation_block
    super collection
    @transformation_block = transformation_block
  end

  def to_a
    map do |item|
      @transformation_block.call item
    end
  end
end
