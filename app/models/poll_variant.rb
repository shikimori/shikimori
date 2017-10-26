class PollVariant < ApplicationRecord
  acts_as_votable

  belongs_to :poll, touch: true

  validates :label, presence: true

  def label_html
    BbCodes::Text.call label
  end
end
