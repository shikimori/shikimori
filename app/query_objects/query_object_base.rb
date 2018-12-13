class QueryObjectBase
  prepend ActiveCacher.instance
  extend DslAttribute

  QUERY_METHODS = %i[joins includes select where order limit offset none]
  DELEGATE_METHODS = %i[== === eql? equal?]

  pattr_initialize :scope

  def to_a
    @scope.to_a
  end

  def to_ary
    @scope.to_a
  end

  def [] index
    @scope.to_a[index]
  end

  def paginate page, limit
    new_scope = @scope
      .offset(limit * (page - 1))
      .limit(limit)

    chain PaginatedCollection.new(new_scope, page, limit)
  end

  def paginate_n1 page, limit
    new_scope = @scope
      .offset(limit * (page - 1))
      .limit(limit + 1)

    chain PaginatedCollection.new(new_scope, page, limit)
  end

  QUERY_METHODS.each do |method_name|
    define_method method_name do |*args|
      chain @scope.public_send(method_name, *args)
    end
  end

  DELEGATE_METHODS.each do |method_name|
    define_method method_name do |*args|
      @scope.send(method_name, *args)
    end
  end

  def transform &block
    chain TransformedCollection.new(@scope, block)
  end

  def respond_to? *args
    super(*args) || @scope.respond_to?(*args)
  end

  def respond_to_missing? *args
    super(*args) || @scope.send(:respond_to_missing?, *args)
  end

  def method_missing method, *args, &block # rubocop:disable MethodMissingSuper
    @scope.send method, *args, &block
  end

private

  def chain scope
    self.class.new scope
  end
end
