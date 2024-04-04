class QueryObjectBase
  prepend ActiveCacher.instance
  extend DslAttribute

  QUERY_METHODS = %i[
    joins
    includes
    preload
    eager_load
    references
    select
    where
    not
    or
    order
    limit
    offset
    none
    except
  ] + (defined?(ArLazyPreload) ? %i[lazy_preload] : [])
  DELEGATE_METHODS = %i[== === eql? equal?]

  vattr_initialize :scope

  def to_a
    @scope.to_a
  end

  def to_ary
    @scope.to_a
  end

  def [] index
    @scope.to_a[index]
  end

  def paginate page, limit, offset = 0
    new_scope = @scope
      .offset(offset + (limit * (page - 1)))
      .limit(limit)

    chain PaginatedCollection.new(new_scope, page, limit)
  end

  def paginate_n1 page, limit
    new_scope = @scope
      .offset(limit * (page - 1))
      .limit(limit + 1)

    chain PaginatedCollection.new(new_scope, page, limit)
  end

  def paginated_slice page, limit
    chain PaginatedCollection.new(@scope, page, limit)
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

  def lazy_map &block
    chain TransformedCollection.new(@scope, :map, block)
  end

  def lazy_filter &block
    chain TransformedCollection.new(@scope, :filter, block)
  end

  def respond_to?(*)
    super(*) || @scope.respond_to?(*)
  end

  def respond_to_missing?(*)
    super(*) || @scope.send(:respond_to_missing?, *)
  end

  def method_missing(method, *, &)
    @scope.send(method, *, &)
  end

private

  def chain scope
    self.class.new scope
  end
end
