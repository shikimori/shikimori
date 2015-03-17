class RecommendationIgnore < ActiveRecord::Base
  belongs_to :user, touch: true
  belongs_to :target, polymorphic: true

  # заблокировать франшизу для пользователя
  def self.block entry, user
    ids = ChronologyQuery.new(entry).fetch.map(&:id) + [entry.id]
    imported = RecommendationIgnore.where(user_id: user.id, target_id: ids, target_type: entry.class.name).pluck(:target_id)
    ids = ids - imported

    entries = ids.uniq.map do |id|
      RecommendationIgnore.new user_id: user.id, target_id: id, target_type: entry.class.name
    end
    RecommendationIgnore.import entries
    user.touch

    (ids + [entry.id]).uniq

  rescue ActiveRecord::RecordNotUnique
    [entry.id]
  end

  # список заблокированного для пользователя
  def self.blocked klass, user
    RecommendationIgnore
      .where(user_id: user.id, target_type: klass.name)
      .order(:id)
      .pluck(:target_id)
  end
end
