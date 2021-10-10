class RepositoryBase
  include Singleton
  include Enumerable

  attr_implement :scope

  delegate :[], to: :collection

  def each
    collection.each_value do |entry|
      yield entry
    end
  end

  def find *args
    if block_given?
      super

    elsif args[0].is_a? Array
      args[0].map { |id| find id }

    else
      id = args[0].to_i

      collection[id] ||
        (reset && collection[id]) ||
        raise(ActiveRecord::RecordNotFound)
    end
  end

  def reset
    @collection = nil
    true
  end

  def self.find *args
    instance.find(*args)
  end

private

  def collection
    @collection ||= scope.index_by(&:id)
  end
end
