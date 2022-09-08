class TransformedCollection
  include Enumerable
  delegate :==, :eql?, :equal?, to: :transformed

  def initialize collection, transformation, action = nil, &block
    @collection = collection
    @transformation = transformation
    @action = action || block
  end

  def each
    transformed.each { |map| yield map }
  end

  def transformed
    @transformed ||= @collection.send(@transformation) do |item|
      @action.call item
    end
  end
  alias to_a transformed

  def respond_to? method, *args
    # rails 6.1 fix to prevent usage of PreloadCollectionIterator in actionview/lib/action_view/renderer/collection_renderer.rb:107
    return false if method == :preload_associations && transformed.present?

    super(method, *args) ||
      transformed.respond_to?(method, *args) ||
      @collection.respond_to?(method, *args)
  end

  def method_missing method, *args, &block
    target = transformed.respond_to?(method) ? transformed : @collection
    target.send method, *args, &block
  end

private

  def respond_to_missing? method, *args
    # rails 6.1 fix to prevent usage of PreloadCollectionIterator in actionview/lib/action_view/renderer/collection_renderer.rb:107
    return false if method == :preload_associations && transformed.present?

    super(method, *args) ||
      transformed.send(:respond_to_missing?, method, *args) ||
      @collection.send(:respond_to_missing?, method, *args)
  end
end
