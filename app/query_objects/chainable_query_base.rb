class ChainableQueryBase
  extend DslAttribute

  pattr_initialize :relation

  dsl_attribute :includes
  dsl_attribute :order_field

  attr_reader :should_decorate
  attr_reader :sort_field
  attr_reader :sort_order

  attr_reader :page
  attr_reader :limit

  attr_reader :postloaded

  def result
    @relation = @relation.includes(*@includes) if @includes
    @relation = order @order_field if @order_field

    @relation = paginate_collection(@relation) if @page

    print @relation if @sql

    @relation = apply_filters(@relation) if @collection_filters
    @relation = decorate_collection(@relation) if @should_decorate
    @relation = sort_collection(@relation) if @sort_field && @sort_order

    if @postloaded
      postload_collection @relation
    else
      @relation
    end
  end

  def paginate page, limit
    @page = page
    @limit = limit
    self
  end

  def postload page, limit
    @page = page
    @limit = limit
    @postloaded = true
    self
  end

  def decorate
    @should_decorate = true
    self
  end

  def sql
    @sql = true
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

  def limit *args
    @relation = @relation.limit *args
    self
  end

  def includes *args
    @relation = @relation.includes *args
    self
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

  def paginate_collection relation
    relation
      .offset(@limit * (@page-1))
      .limit(@limit + 1)
  end

  def postload_collection collection
    [collection.take(@limit), collection.size == @limit+1]
  end

  def print relation
    puts '-------------------------------'
    puts relation.to_sql
    puts '-------------------------------'
  end
end
