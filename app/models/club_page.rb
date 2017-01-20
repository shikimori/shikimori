class ClubPage < ActiveRecord::Base
  belongs_to :club, touch: true
  belongs_to :parent, class_name: ClubPage.name
  has_many :children,
    class_name: ClubPage.name,
    foreign_key: :parent_id,
    dependent: :destroy

  validates :club, :name, :text, presence: true

  def to_param
    "#{id}-#{name.permalinked}"
  end
end
