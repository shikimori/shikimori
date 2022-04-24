class TransformedCollection
  include Enumerable
  delegate :==, :eql?, :equal?, to: :mapped

  def initialize collection, mapper = nil, &block
    @collection = collection
    @mapper = mapper || block
  end

  def each
    mapped.each { |map| yield map }
  end

  def mapped
    @mapped ||= @collection.map do |item|
      @mapper.call item
    end
  end
  alias to_a mapped

  def respond_to? method, *args
    # rails 6.1 fix to prevent usage of PreloadCollectionIterator in actionview/lib/action_view/renderer/collection_renderer.rb:107
    return false if method == :preload_associations && mapped.present?

    super(method, *args) ||
      mapped.respond_to?(method, *args) ||
      @collection.respond_to?(method, *args)
  end

  def method_missing method, *args, &block
    target = mapped.respond_to?(method) ? mapped : @collection
    target.send method, *args, &block
  end

private

  def respond_to_missing? method, *args
    # rails 6.1 fix to prevent usage of PreloadCollectionIterator in actionview/lib/action_view/renderer/collection_renderer.rb:107
    return false if method == :preload_associations && mapped.present?

    super(method, *args) ||
      mapped.send(:respond_to_missing?, method, *args) ||
      @collection.send(:respond_to_missing?, method, *args)
  end
end

# class TransformedCollection < SimpleDelegator
#   include Enumerable
#
#   def initialize collection, transformation
#     @original = collection
#     super @original
#     @transformation = transformation
#   end
#
#   def each
#     to_a.each { |item| yield item }
#   end
#
#   def to_a
#     1/0
#     @transformed ||= begin
#       collection = __getobj__.map { |item| @transformation.call(item) }
#       __setobj__(collection)
#       collection
#     end
#   end
#
#   def respond_to? *args
#     super(*args) || @original.respond_to?(*args)
#   end
#
#   def respond_to_missing? *args
#     super(*args) || @original.send(:respond_to_missing?, *args)
#   end
#
#   def method_missing method, *args, &block
#     @original.send method, *args, &block
#   end
#
#   # def method_missing method, *args, &block
#   #   raise @transformed.class.to_json
#   #   if @transformed.present? && !@transformed.send(:respond_to_missing?, method) &&
#   #       @original.send(:respond_to_missing?, method)
#   #     @original.send method, *args, &block
#   #   else
#   #     super method, *args, &block
#   #   end
#   # end
#
# # private
# #
# #   def respond_to_missing? method, include_private = false
# #     super(method, include_private)# ||
# #       # (@transformed.present? && @original.send(:respond_to_missing?, method, include_private))
# #   end
# end
