class MappedCollection
  include Enumerable
  delegate :==, :eql?, :equal?, to: :maps

  def initialize collection, &block
    @collection = collection
    @mapper = block
  end

  def each
    maps.each { |map| yield map }
  end

private

  def maps
    @maps ||= @collection.map do |item|
      @mapper.call item
    end
  end

  def respond_to? *args
    super(*args) || maps.respond_to?(*args) || @collection.respond_to?(*args)
  end

  def method_missing method, *args, &block
    target = maps.respond_to?(method) ? maps : @collection
    target.send method, *args, &block
  end
end
