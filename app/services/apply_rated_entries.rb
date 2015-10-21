class ApplyRatedEntries
  pattr_initialize :user

  def call entries
    entries.map do |entry|
      RatedEntry.new entry, match(entries, entry)
    end
  end

private

  def match entries, entry
    return unless user
    rates(entries).find { |v| v.target_id == entry.id }
  end

  def rates entries
    @rates ||= {}
    @rates[klass(entries.first)] ||= user.send(rates_relation entries.first)
      .where(target_id: entries.map(&:id))
      .to_a
  end

  def klass entry
    entry.anime? ? Anime : Manga
  end

  def rates_relation entry
    "#{klass(entry).name.downcase}_rates"
  end
end
