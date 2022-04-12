class Poll < ApplicationRecord
  include AASM
  include Translation

  acts_as_votable

  belongs_to :user
  has_many :variants, -> { order :id },
    class_name: 'PollVariant',
    inverse_of: :poll,
    dependent: :destroy

  enumerize :width,
    in: Types::Poll::Width.values,
    predicates: true

  validates :name, presence: true, length: { maximum: 255 }
  validates :text, length: { maximum: 10_000 }

  aasm column: 'state', create_scopes: false do
    state Types::Poll::State[:pending], initial: true
    state Types::Poll::State[:started]
    state Types::Poll::State[:stopped]

    event :start do
      transitions to: Types::Poll::State[:started],
        from: Types::Poll::State[:pending],
        if: -> { persisted? && variants.many? }
    end
    event :stop do
      transitions to: Types::Poll::State[:stopped],
        from: Types::Poll::State[:started]
    end
  end

  accepts_nested_attributes_for :variants

  def name
    return super if super.present? || new_record?

    i18n_t 'name', id: id
  end

  def bb_code
    "[poll=#{id}]"
  end

  def text_html
    BbCodes::Text.call text
  end
end
