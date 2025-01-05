class Poll < ApplicationRecord
  include AASM
  include Translation
  include AntispamConcern

  acts_as_votable
  antispam(
    per_day: 15,
    user_id_key: :user_id
  )

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
      transitions(
        from: Types::Poll::State[:pending],
        to: Types::Poll::State[:started],
        if: -> { persisted? && variants.many? }
      )
    end
    event :stop do
      transitions(
        from: Types::Poll::State[:started],
        to: Types::Poll::State[:stopped]
      )
    end
  end

  accepts_nested_attributes_for :variants

  MAX_VARIANTS = 40

  def variants_attributes= attributes
    attributes = attributes.slice(0, MAX_VARIANTS) if attributes.size > MAX_VARIANTS
    super
  end

  def name
    return super if super.present? || new_record?

    i18n_t 'name', id:
  end

  def bb_code
    "[poll=#{id}]"
  end

  def text_html
    BbCodes::Text.call(
      Moderations::Banhammer.instance.censor(text || '')
    )
  end
end
