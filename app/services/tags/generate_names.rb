class Tags::GenerateNames
  method_object :names

  SHORT_NAME_SIZE = 6
  MAXIMUM_NAME_DIFFERENCE = 0.75 # i.e. name can be shortened for 25%

  def call
    finalize(correct(fix(@names)))
  end

  def self.cleanup tag
    tag
      .downcase
      .unaccent
      .tr('_', ' ')
      .gsub(/\b(?:#{SEASON_WORDS.join '|'})\b/, ' ')
      .gsub(/\bs?[ivx\d]+\b/, ' ')
      .gsub(/\b(?:#{SPECIAL_WORDS.join '|'})\b/, ' ')
      .gsub(/  +/, ' ')
      .strip
  end

private

  def fix names
    Array(names)
      .map { |name| Tags::Cleanup.instance.call name }
      .uniq
  end

  def correct names
    names
      .flat_map { |name| multiply name }
      .flat_map { |name| shorten name }
      .uniq
  end

  def finalize names
    names
      .map { |name| simplify(name).gsub(/  +/, ' ').strip }
      .uniq
      .select(&:present?)
  end

  def simplify name
    if name.contains_cjkv?
      name
    else
      name.gsub(/[^\wА-Яа-я ]+/, ' ')
    end
  end

  def multiply name
    separator = name.rindex(/[:(-]/)

    if separator && separator > SHORT_NAME_SIZE
      new_name = name[0, separator]

      [name, new_name]
    else
      name
    end
  end

  def shorten name
    separator = name.rindex(/ /)

    if separator && separator > SHORT_NAME_SIZE
      new_name = name[0, separator]

      if new_name.size * 1.0 / name.size > MAXIMUM_NAME_DIFFERENCE
        [name, new_name].flatten
      else
        name
      end
    else
      name
    end
  end
end
