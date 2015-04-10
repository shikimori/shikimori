class ExtendedUserRate < SimpleDelegator
  attr_reader :user_rate

  def initialize user_rate_with_data
    super
    @user_rate = user_rate_with_data
  end

  def rating
    I18n.t "RatingShort.#{super}" if super != 'None'
  end
end
