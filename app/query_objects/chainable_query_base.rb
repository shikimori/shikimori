class ChainableQueryBase
  extend DslAttribute

  pattr_initialize :relation

  dsl_attribute :includes
  dsl_attribute :order_field

  attr_reader :sort_field
  attr_reader :sort_order

  attr_reader :page
  attr_reader :limit

  attr_reader :paginated

  def result
    @relation = @relation.includes(*@includes) if @includes
    @relation = order @order_field if @order_field

    @relation = apply_filters @relation if @collection_filters
    @relation = apply_maps @relation if @collection_maps
    @relation = sort_collection @relation if @sort_field && @sort_order

    if @paginated
      paginate_collection @relation
    else
      @relation
    end
  end

  def paginate page, limit
    @page = page
    @limit = limit
    @paginated = true

    @relation = relation
      .offset(@limit * (@page-1))
      .limit(@limit)

    self
  end

  def sort sort_field, sort_order
    @sort_field = sort_field
    @sort_order = sort_order
    self
  end

  # default activerecord methods
  def where *args
    @relation = @relation.where *args
    self
  end

  def where_not *args
    @relation = @relation.where.not *args
    self
  end

  def except *args
    @relation = @relation.except *args
    self
  end

  def order *args
    @relation = @relation.order *args
    self
  end

  def order! *args
    except :order
    order *args
  end

  def limit *args
    @relation = @relation.limit *args
    self
  end

  def includes *args
    @relation = @relation.includes *args
    self
  end

  def joins *args
    @relation = @relation.joins *args
    self
  end

  def offset *args
    @relation = @relation.offset *args
    self
  end

  def limit *args
    @relation = @relation.limit *args
    self
  end

  def size
    relation.size
  end

private

  def collection_filter &block
    @collection_filters ||= []
    @collection_filters << block
  end

  def apply_filters relation
    @collection_filters.inject(relation) do |result, filter|
      result.select { |v| filter.call v }
    end
  end

  def collection_map &block
    @collection_maps ||= []
    @collection_maps << block
  end

  def apply_maps relation
    @collection_maps.inject(relation) do |result, filter|
      result.map { |v| filter.call v }
    end
  end

  def paginate_collection collection
    PaginatedCollection.new(
      collection,
      @page,
      collection.size == @limit ? @page + 1 : @page
    )
  end
end
