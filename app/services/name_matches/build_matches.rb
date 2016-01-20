class NameMatches::BuildMatches < ServiceObjectBase
  pattr_initialize :entry

  def call
    alternatives
      .compact
      .map { |attrs| NameMatch.build attrs }
  end

private

  def alternatives
    NameMatch::GROUPS.flat_map do |group|
      send :"#{group}_names", entry
    end
  end

  # заполнение кеша
  # def build_cache
    # names = {
      # name: main_names(entry).compact,
      # alt: alt_names(entry).compact,
      # alt2: alt2_names(entry).compact,
      # russian: russian_names(entry).compact
    # }
    # names.each {|k,v| v.map!(&:downcase) }
    # names[:alt3] = alt3_names(entry, names[:alt2])

    # names.each {|k,v| names[k] = (v + v.map {|name| fix name }).uniq }

    # names.each do |group,names|
      # names.each do |name|
        # cache[group][name] ||= []
        # cache[group][name] << entry
      # end
    # end

    # # идентификаторы привязанных сервисов
    # entry
      # .links
      # .select {|v| @services.include?(v.service.to_sym) }
      # .each {|link| cache[link.service.to_sym][link.identifier] = entry } if @services.present?
  # end

  def main_names entry
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
    alt_names_1 = alt1_names entry

    names = alt_names_1.map { |name| fix(phrase_variants name, entry.kind) }.compact.flatten
    (
      names +
      names.map {|v| v.gsub('!', '') } +
      alt_names_1.select {|v| v =~ /!/ }.map {|v| v.gsub('!', '') }
    ).uniq
  end

  def russian_names entry
    names = [entry.russian, fix(entry.russian), fix(phrase_variants(entry.russian))]
      .flatten
      .compact
      .map(&:downcase)

    (names + names.map {|v| v.gsub('!', '') }).uniq
  end
end
