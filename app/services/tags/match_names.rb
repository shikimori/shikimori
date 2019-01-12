class Tags::MatchNames
  method_object %i[names! tags! no_correct!]

  SHORT_NAME_SIZE = 6

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
      .uniq
  end

  def multiply name
    separator = name.rindex(/[_:( ]/)

    if separator && separator > SHORT_NAME_SIZE
      [name, multiply(name[0, separator])].flatten
    else
      [name]
    end
  end
end
