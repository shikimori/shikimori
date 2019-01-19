class Tags::GenerateNames
  method_object :names

  SHORT_NAME_SIZE = 6
  MAXIMUM_NAME_DIFFERENCE = 0.75 # i.e. name can be shortened for 25%

  def call
    finalize(correct(fix(@names)))
  end

private

  def fix names
    Array(names)
      .map do |name|
        name
          .downcase
          .tr('_', ' ')
          .gsub(/ (?:season|сезон) ?(?:i+|\d)\b/, ' ')
          .gsub(/ s?(?:i+|\d)\b/, ' ')
          .gsub(/ (?:tv|movie|ova|ona)\b/, ' ')
          .gsub(/  +/, ' ')
          .strip
      end
      .uniq
  end

  def correct names
    names
      .flat_map { |v| multiply v }
      .flat_map { |v| shorten v }
      .uniq
  end

  def finalize names
    names
      .map do |name|
        name
          .gsub(/[^\w ]+/, ' ')
          .gsub(/  +/, ' ')
          .strip
      end
      .uniq
      .sort
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
