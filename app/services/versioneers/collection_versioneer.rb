class Versioneers::CollectionVersioneer < Versioneers::FieldsVersioneer
  pattr_initialize :item, :association_name

private

  def version_klass _
    Versions::CollectionVersion
  end

  def changes collection, version
    old_value = version.current_value(@association_name).map { |v| convert v }
    new_value = collection.map { |v| convert v }

    if old_value.to_s != new_value.to_s
      { @association_name => [old_value, new_value] }
    else
      {}
    end
  end

  def convert hash
    fixed_hash = hash.each_with_object({}) do |(key, value), memo|
      memo[key] = fix(value)
    end

    Hash[fixed_hash.sort_by(&:first)]
  end

  def fix value
    if value.nil?
      ''
    elsif value.is_a? Numeric
      value.to_s
    else
      value
    end
  end
end
