class Publishers
  include Singleton

  delegate :[], to: :collection

  def reset
    @collection = nil
  end

private

  def collection
    @collection ||= Publisher.all.each_with_object({}) do |publisher, memo|
      memo[publisher.id] = publisher
    end
  end
end
