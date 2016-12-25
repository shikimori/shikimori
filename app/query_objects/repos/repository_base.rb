class Repos::RepositoryBase
  include Singleton

  attr_implement :scope

  delegate :[], :size, to: :collection

  def reset
    @collection = nil
  end

private

  def collection
    @collection ||= scope.each_with_object({}) do |entry, memo|
      memo[entry.id] = entry
    end
  end
end
