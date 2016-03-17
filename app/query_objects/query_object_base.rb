class QueryObjectBase
  prepend ActiveCacher.instance
  extend DslAttribute

  QUERY_METHODS = %i(joins includes select where order limit offset)

  pattr_initialize :scope
  delegate :==, :eql?, :equal?, to: :scope

  def paginate page, limit
    new_scope = @scope
      .offset(limit * (page-1))
      .limit(limit)

    chain PaginatedCollection.new(new_scope, page, limit)
  end

  QUERY_METHODS.each do |method_name|
    define_method method_name do |*args|
      chain @scope.public_send(method_name, *args)
    end
  end

private

  def chain scope
    self.class.new scope
  end

  def respond_to? *args
    super(*args) || @collection.respond_to?(*args)
  end

  def method_missing method, *args, &block
    @scope.send method, *args, &block
  end
end
