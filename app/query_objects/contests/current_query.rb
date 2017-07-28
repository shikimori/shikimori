class Contests::CurrentQuery
  method_object

  def call
    Contest
      .where(state: :started)
      .where('started_on <= ?', Time.zone.today)
      .or(Contest.where(state: :proposing))
      .order(state: :desc, started_on: :asc)
  end
end
