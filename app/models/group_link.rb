class GroupLink < ActiveRecord::Base
  belongs_to :group, touch: true
  belongs_to :linked, polymorphic: true
end
