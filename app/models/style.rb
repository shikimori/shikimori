class Style < ActiveRecord::Base
  belongs_to :owner, polymorphic: true

  validates :owner, :name, :css, presence: true
end
