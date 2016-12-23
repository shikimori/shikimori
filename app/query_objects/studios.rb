class Studios
  include Singleton

  delegate :[], to: :collection

  def reset
    @collection = nil
  end

private

  def collection
    @collection ||= Studio.all.each_with_object({}) do |studio, memo|
      memo[studio.id] = studio
    end
  end
end
