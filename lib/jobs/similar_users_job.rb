class SimilarUsersJob < Struct.new(:user_id, :klass, :threshold, :cache_key)
  def perform
    Rails.cache.fetch cache_key, expires_in: 2.weeks do
      fetch
    end
  end

private
  def fetch
    SimilarUsersService.new(User.find(user_id), klass, threshold).fetch
  end

  def klass
    super.constantize
  end
end
