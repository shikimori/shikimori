class Tags::MatchNames
  method_object %i[names! tags! no_correct]

  SHORT_NAME_SIZE = 6
  MAXIMUM_NAME_DIFFERENCE = 0.75 # i.e. name can be shortened for 25%

  def call
    tags_map = build_tags_map

    (generate(@names) & tags_map.keys)
      .flat_map do |fixed_tag|
        tags_map[fixed_tag]
      end
      .uniq
  end

private

  def build_tags_map
    @tags.each_with_object({}) do |tag, memo|
      generate([tag]).each do |fixed_tag|
        memo[fixed_tag] ||= []
        memo[fixed_tag].push tag
      end
    end
  end

  def generate names
    if @no_correct
      fix(names)
    else
      correct fix(names)
    end
  end

  def fix names
    names
      .map { |v| v.gsub(/['"]/, '').tr(' ', '_').downcase }
      .flat_map { |v| [v, v.tr('-', '_')] }
  end

  def correct names
    names
      .flat_map { |v| [v, v.sub('!', ''), v.sub('!', '').sub('!', '')] }
      .flat_map { |v| multiply v }
      .flat_map { |v| shorten v }
      .uniq
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
    separator = name.rindex(/[_ ]/)

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
