class ResetTopicsIndex < ActiveRecord::Migration[5.2]
  def change
    unless Rails.env.test?
      TopicsIndex.reset!
    end
  end
end
