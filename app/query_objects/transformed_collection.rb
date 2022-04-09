class TransformedCollection < SimpleDelegator
  include Enumerable

  def initialize collection, transformation
    super collection
    @transformation = transformation
  end

  def each
    to_a.each { |item| yield item }
  end

  def to_a
    @collection ||= begin
      collection = __getobj__.map { |item| @transformation.call(item) }
      __setobj__(collection)
      collection
    end
  end
end
