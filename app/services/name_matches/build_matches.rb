class NameMatches::BuildMatches < ServiceObjectBase
  pattr_initialize :entry

  delegate :fix, :phrase_variants, to: :phraser

  GROUPS = NameMatch::GROUPS

  def call
    GROUPS.flat_map { |group| build group }.uniq(&:phrase)
  end

private

  def build group
    fix(send(:"#{group}_names", entry)).uniq.map do |phrase|
      NameMatch.new(
        group: GROUPS.index(group),
        priority: entry.kind == :tv ? 0 : 1,
        phrase: phrase,
        target: entry
      )
    end
  end

  def predefined_names entry
    config.predefined_names(entry.class)
      .select { |name, id| id == entry.id }
      .map(&:first)
  end

  def name_names entry
    names = [entry.name, "#{entry.name} #{entry.kind}"]
    aired_on = ["#{entry.name} #{entry.aired_on.year}"] if entry.aired_on

    names + (aired_on || [])
  end

  def alt_names entry
    synonyms = entry.synonyms.map { |v| "#{v} #{entry.kind}" } + (entry.aired_on ? entry.synonyms.map {|v| "#{v} #{entry.aired_on.year}" } : []) if entry.synonyms
    english = entry.english.map { |v| "#{v} #{entry.kind}" }  + (entry.aired_on ? entry.english.map {|v| "#{v} #{entry.aired_on.year}" } : []) if entry.english

    (synonyms || []) + (english || [])
  end

  def alt2_names entry
    [entry.name] + (entry.synonyms ? entry.synonyms : []) + (entry.english ? entry.english : [])
  end

  def alt3_names entry
    alternatives = alt_names entry

    names = alternatives.map { |name| fix(phrase_variants name, entry.kind) }.compact.flatten
    (
      names +
      names.map {|v| v.gsub('!', '') } +
      alternatives.select {|v| v =~ /!/ }.map {|v| v.gsub('!', '') }
    ).uniq
  end

  def russian_names entry
    names = [entry.russian, fix(entry.russian), fix(phrase_variants(entry.russian))]
      .flatten
      .compact
      .map(&:downcase)

    (names + names.map {|v| v.gsub('!', '') }).uniq
  end

  def phraser
    @phraser ||= NameMatches::Phraser.new
  end

  def config
    NameMatches::Config.instance
  end
end
