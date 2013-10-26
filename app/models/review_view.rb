class ReviewView < ActiveRecord::Base
  belongs_to :review
  belongs_to :user

  # чёртов гем ломает присвоение ассоциаций в FactoryGirl, и я не знаю, как это быстро починить другим способом
  primary_keys = :user_id, :review_id unless Rails.env.test?
end
