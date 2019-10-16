class FavoriteEntry < SimpleDelegator
  attr_reader :favorite

  def initialize entry, favorite
    super entry
    @favorite = favorite
  end
end
