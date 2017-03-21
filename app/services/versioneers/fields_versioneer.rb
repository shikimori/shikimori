class Versioneers::FieldsVersioneer
  pattr_initialize :item

  SPLITTED_DATE_FIELD = /
    (?<field> [\w-]+ )
    \( (?<index>[1-3]i) \)
    $
  /mix

  def premoderate params, author = nil, reason = nil
    create_version params.to_h, author, reason
  end

  def postmoderate params, author = nil, reason = nil
    version = premoderate params.to_h, author, reason
    version.auto_accept! if version.persisted? && version.can_auto_accept?
    version
  end

private

  def create_version params, user, reason
    diff = changes params

    version_klass(diff).create(
      item: item,
      user: user,
      item_diff: diff,
      reason: reason
    )
  end

  def changes new_values
    convert_hash(new_values).each_with_object({}) do |(field, new_value), memo|
      if item.send(field).to_s != new_value.to_s
        memo[field.to_s] = [item.send(field), new_value]
      end
    end
  end

  def version_klass diff
    diff['description_ru'] || diff['description_en'] ?
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
