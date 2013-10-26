class Forum < ActiveRecord::Base
  has_many :sections, :order => :position
end
