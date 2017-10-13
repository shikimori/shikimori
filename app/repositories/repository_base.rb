class RepositoryBase
  include Singleton
  include Enumerable

  attr_implement :scope

  delegate :[], to: :collection

  def each
    collection.values.each do |entry|
      yield entry
    end
  end

  def find id
    collection[id] ||
      (reset && collection[id]) ||
      raise(ActiveRecord::RecordNotFound)
  end

  def reset
    @collection = nil
    true
  end

private

  def collection
    @collection ||= scope.each_with_object({}) do |entry, memo|
      memo[entry.id] = entry
    end
  end
end
