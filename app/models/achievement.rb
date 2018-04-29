class Achievement < ApplicationRecord
  belongs_to :user

  validates :user, :neko_id, :level, :progress, presence: true

  enumerize :neko_id,
    in: Types::Achievement::NekoId.values,
    predicates: { prefix: true }

  %i[
    group
    group_name
    image
    border_color
    title
    hint
    text
    sort_criteria
    common?
    genre?
    franchise?
  ].each { |field| delegate field, to: :neko }

private

  def neko
    @neko ||= NekoRepository.instance.find neko_id, level
  end
end
