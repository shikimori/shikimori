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

  def find ids
    if ids.is_a? Array
      ids.map { |id| find id }

    else
      id = ids.to_i

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
    @collection ||= scope.each_with_object({}) do |entry, memo|
      memo[entry.id] = entry
    end
  end
end
