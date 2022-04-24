class Versions::DescriptionVersion < Version
  def reevaluate_state **_args
    self.state = measure_changes.enough? ? 'accepted' : 'taken'
    save if changed?
  end

  def optionally_takeable?
    true
  end

private

  def measure_changes
    description = item_diff['description_ru'] || item_diff['description_en']
    MeasureChanges.new description[0], description[1]
  end
end
