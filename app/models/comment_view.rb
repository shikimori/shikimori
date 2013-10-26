class CommentView < ActiveRecord::Base
  belongs_to :comment
  belongs_to :user

  # чёртов гем ломает присвоение ассоциаций в FactoryGirl, и я не знаю, как это быстро починить другим способом
  primary_keys = :user_id, :comment_id unless Rails.env.test?
end
