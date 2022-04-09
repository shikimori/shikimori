class TransformedCollection < SimpleDelegator
  include Enumerable

  def initialize collection, transformation
    @original = collection
    super @original
    @transformation = transformation
  end

  def each
    to_a.each { |item| yield item }
  end

  def to_a
    @transformed ||= begin
      collection = __getobj__.map { |item| @transformation.call(item) }
      __setobj__(collection)
      collection
    end
  end

  def respond_to_missing? *args
    super(*args) ||
      (@transformed.present? && @original.send(:respond_to_missing?, *args))
  end

  def method_missing method, *args, &block
    if @transformed.present? && !@transformed.respond_to_missing?(method) &&
        @original.respond_to_missing?(method)
      @original.send method, *args, &block
    else
      super method, *args, &block
    end
  end
end
