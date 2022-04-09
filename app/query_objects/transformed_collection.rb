class TransformedCollection
  include Enumerable
  delegate :==, :eql?, :equal?, to: :mappings

  def initialize collection, mapper = nil, &block
    @collection = collection
    @mapper = mapper || block
  end

  def each
    mappings.each { |map| yield map }
  end

  def mappings
    @mappings ||= @collection.map do |item|
      @mapper.call item
    end
  end
  alias to_a mappings

  def respond_to? *args
    super(*args) || mappings.respond_to?(*args) || @collection.respond_to?(*args)
  end

  def method_missing method, *args, &block
    target = mappings.respond_to?(method) ? mappings : @collection
    target.send method, *args, &block
  end

private

  def respond_to_missing? *args
    super(*args) ||
      mappings.send(:respond_to_missing?, *args) ||
      @collection.send(:respond_to_missing?, *args)
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
