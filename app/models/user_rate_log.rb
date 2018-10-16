class UserRateLog < ApplicationRecord
  belongs_to :user
  belongs_to :target, polymorphic: true, optional: true
  belongs_to :oauth_application, optional: true

  belongs_to :anime, foreign_key: :target_id, optional: true
  belongs_to :manga, foreign_key: :target_id, optional: true

  def action
    if diff&.dig('id', 0).nil? && !diff&.dig('id', 1).nil?
      :create
    elsif !diff&.dig('id', 0).nil? && diff&.dig('id', 1).nil?
      :destroy
    else
      :update
    end
  end
end
