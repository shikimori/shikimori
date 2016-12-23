class Genres
  include Singleton

  delegate :[], to: :collection

  def reset
    @collection = nil
  end

private

  def collection
    @collection ||= Genre.all.each_with_object({}) do |genre, memo|
      memo[genre.id] = genre
    end
  end
end
