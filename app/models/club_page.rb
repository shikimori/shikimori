class ClubPage < ApplicationRecord
  include TopicsConcern

  acts_as_list scope: %i[club_id parent_page_id]

  belongs_to :club, touch: true
  belongs_to :user
  belongs_to :parent_page, class_name: 'ClubPage', optional: true
  has_many :child_pages, -> { ordered },
    class_name: 'ClubPage',
    foreign_key: :parent_page_id,
    dependent: :destroy

  enumerize :layout,
    in: Types::ClubPage::Layout.values,
    predicates: { prefix: true },
    default: Types::ClubPage::Layout[:menu]

  validates :name, presence: true
  validates :name, length: { maximum: 255 }
  validates :text, length: { maximum: 150_000 }, unless: :special_club?
  validates :text, length: { maximum: 450_000 }, if: :special_club?

  delegate :censored?, to: :club, allow_nil: true
  alias topic_user user

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

private

  def special_club?
    Club::SPECIAL_CLUB_IDS.include? club_id
  end
end
