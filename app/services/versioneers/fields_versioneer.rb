class Versioneers::FieldsVersioneer
  pattr_initialize :item, %i[associated]

  SPLITTED_DATE_FIELD = /
    (?<field> [\w-]+ )
    \( (?<index>[1-3]i) \)
    $
  /mix

  def premoderate params, author = nil, reason = nil
    create_version params, author, reason
  end

  # TODO: merge premoderate + postmoderate
  # fix places where used premoderate + manual auto_accept after
  def postmoderate params, author = nil, reason = nil
    version = premoderate params, author, reason

    if version.persisted? && Ability.new(author).can?(:auto_accept, version)
      version.auto_accept!
    end

    version
  end

private

  def create_version params, user, reason
    version_klass(params)
      .create(
        item: item,
        user: user,
        reason: reason,
        state: 'pending'
      ) do |version|
        version.item_diff = changes params, version
        version.associated = @associated
      end
  end

  def changes new_values, version
    convert_hash(new_values).each_with_object({}) do |(field, new_value), memo|
      if item.send(field).to_s != new_value.to_s
        memo[field.to_s] = [version.current_value(field), new_value]
      end
    end
  end

  def version_klass params
    params[:description_ru] || params[:description_en] ?
      Versions::DescriptionVersion :
      Version
  end

  def convert_hash hash
    hash.each_with_object({}) do |(key, value), memo|
      if key =~ SPLITTED_DATE_FIELD
        field = $LAST_MATCH_INFO[:field]
        memo[field] ||= convert_date hash, field
      else
        memo[key] = value
      end
    end
  end

  def convert_date hash, field
    year = hash["#{field}(1i)"].to_i
    month = hash["#{field}(2i)"].blank? ? 1 : hash["#{field}(2i)"].to_i
    day = hash["#{field}(3i)"].blank? ? 1 : hash["#{field}(3i)"].to_i

    year.zero? ? nil : Date.new(year, month, day)
  end
end
