class ContestSuggestion < ActiveRecord::Base
  belongs_to :contest, touch: true
  belongs_to :user
  belongs_to :item, polymorphic: true

  validates :contest, presence: true
  validates :user, presence: true
  validates :item, presence: true

  scope :by_user, -> (user) { where user_id: user.id }
  scope :by_votes, -> { group(:item_id).select('*, count(*) as votes').order('count(*) desc') }

  def self.suggest contest, user, item
    contest.suggestions.create!({
      user_id: user.id,
      item_id: item.id,
      item_type: item.class.name
    })

    suggestions = contest
      .suggestions
      .by_user(user)
      .all

    # удаляем всё после первых трёх вариантов
    suggestions
      .drop(contest.suggestions_per_user)
      .each(&:destroy)

    # удаляем все дубли
    suggestions
      .take(contest.suggestions_per_user)
      .group_by {|v| [v.user_id, v.item_id, v.item_type] }
      .select {|k,v| v.size > 1 }
      .values
      .map {|v| v.drop(1) }
      .flatten
      .each(&:destroy)
  end
end
