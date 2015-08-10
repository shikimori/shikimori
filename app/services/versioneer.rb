class Versioneer
  pattr_initialize :item

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
    Version.create(
      item: item,
      user: user,
      item_diff: changes(params),
      reason: reason
    )
  end

  def changes new_values
    new_values.each_with_object({}) do |(field, new_value), memo|
      memo[field] = [item[field], new_value] if item[field] != new_value
    end
  end
end
