class Tags::MatchNames
  method_object %i[names! tags! no_correct!]

  SHORT_NAME_SIZE = 6
  MAXIMUM_NAME_DIFFERENCE = 0.75 # i.e. name can be shortened for 25%

  def call
    (generate_names & @tags).first
  end

private

  def generate_names
    if @no_correct
      fixed_names
    else
      correct fixed_names
    end
  end

  def fixed_names
    @names
      .map { |v| v.gsub(/['"]/, '').downcase }
      .flat_map { |v| [v, v.tr(' ', '_')] }
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
