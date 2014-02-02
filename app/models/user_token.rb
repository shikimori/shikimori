class UserToken < ActiveRecord::Base
  belongs_to :user, touch: true
end
