class UserRateStatus
  Planned = 'Plan to Watch'
  Watching = 'Watching'
  Completed = 'Completed'
  OnHold = 'On-Hold'
  Dropped = 'Dropped'

  @@data = [
    {name: Planned, id: 0},
    {name: Watching, id: 1},
    {name: Completed, id: 2},
    {name: OnHold, id: 3},
    {name: Dropped, id: 4},
    {name: Planned, id: 5, ignored: true}, # статусы plan to watch с мала. иногда бывают
    {name: Planned, id: 6, ignored: true} # статусы plan to watch с мала. иногда бывают
  ]

  def self.contains(id)
    @@data.each do |v|
      return true if v[:id] == id
    end
    false
  end

  def self.statuses
    @@data.select { |v| !v[:ignored] }
  end

  def self.select_options list_type
    statuses.map do |status|
      [I18n.t("#{list_type}RateStatus.#{status[:name]}"), status[:id]]
    end
  end

  def self.default
    @@data.first[:id]
  end

  def self.get(key)
    if key.class == String
      return @@data.select {|v| v[:name].downcase.gsub(' ', '-') == key.downcase.gsub(' ', '-') }.first[:id]
    elsif key.class == Fixnum
      return @@data.select {|v| v[:id] == key }.first[:name]
    else
      raise 'bad key'
    end
  end
end
