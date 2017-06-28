class Contests::CurrentQuery
  method_object

  def call
    Contest
      .where(state: :started)
      .where('started_on <= ?', Time.zone.today)
      .order(:started_on)
  end
end
