class ClubPage < ApplicationRecord
  acts_as_list scope: %i[club_id parent_page_id]

  belongs_to :club, touch: true
  belongs_to :parent_page, class_name: ClubPage.name, optional: true
  has_many :child_pages, -> { ordered },
    class_name: ClubPage.name,
    foreign_key: :parent_page_id,
    dependent: :destroy

  has_one :topic,
    class_name: Topics::EntryTopics::ClubPageTopic.name,
    as: :linked,
    inverse_of: :linked, # topic always load know its linked
    dependent: :destroy

  enumerize :layout,
    in: Types::ClubPage::Layout.values,
    predicates: { prefix: true },
    default: Types::ClubPage::Layout[:menu]

  validates :club, :name, presence: true
  validates :name, length: { maximum: 255 }

  scope :ordered, -> { order :position, :id }

  def to_param
    "#{id}-#{name.permalinked}"
  end

  def parents
    parent_page ? parent_page.parents + [parent_page] : []
  end

  def siblings
    parent_page ? parent_page.child_pages : club.root_pages
  end
end
