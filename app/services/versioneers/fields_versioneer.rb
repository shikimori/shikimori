class Versioneers::FieldsVersioneer
  pattr_initialize :item

  SPLITTED_DATE_FIELD = /
    (?<field> [\w_-]+ )
    \( (?<index>[1-3]i) \)
    $
  /mix

  def premoderate params, author=nil, reason=nil
    create_version params, author, reason
  end

  def postmoderate params, author=nil, reason=nil
    version = premoderate params, author, reason
    version.auto_accept! if version.persisted?
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
    convert_dates(new_values).each_with_object({}) do |(field, new_value), memo|
      memo[field.to_s] = [item.send(field), new_value] if item.send(field).to_s != new_value.to_s
    end
  end

  def version_klass diff
    diff['description'] ? Versions::DescriptionVersion : Version
  end

  def convert_dates hash
    hash.each_with_object({}) do |(key,value),memo|
      if key =~ SPLITTED_DATE_FIELD
        memo[$~[:field]] ||= Date.new(
          hash[$~[:field] + '(1i)'].to_i,
          hash[$~[:field] + '(2i)'].to_i,
          hash[$~[:field] + '(3i)'].to_i
        )
      else
        memo[key] = value
      end
    end
  end
end
