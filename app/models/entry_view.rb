class EntryView < ActiveRecord::Base
  belongs_to :user
  belongs_to :entry

  # чёртов гем ломает присвоение ассоциаций в FactoryGirl, и я не знаю, как это быстро починить другим способом
  primary_keys = :user_id, :entry_id unless Rails.env.test?
end
