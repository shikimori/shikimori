class Repos::RepositoryBase
  include Singleton

  attr_implement :scope

  delegate :[], :size, to: :collection

  def reset
    @collection = nil
    true
  end

  def find id
    collection[id] ||
      (reset && collection[id]) ||
      raise(ActiveRecord::RecordNotFound)
  end

  def all
    collection.values
  end

private

  def collection
    @collection ||= scope.each_with_object({}) do |entry, memo|
      memo[entry.id] = entry
    end
  end
end
