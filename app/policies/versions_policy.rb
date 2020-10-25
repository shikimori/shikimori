class VersionsPolicy
  pattr_initialize :user, %i[version db_entry field]

  def self.version_allowed? user, version
    new(user, version: version).call
  end

  def self.change_allowed? user, db_entry, field
    new(user, db_entry: db_entry, field: field).call
  end

  def call
    return false unless allowed?

    if changing_restricted_fields.any?
      restriction_change_allowed?
    else
      true
    end
  end

private

  def allowed?
    return false if @user.banned?
    return false if @user.not_trusted_version_changer?
    return false if @user.not_trusted_names_changer? && name_changing?
    return false if @version && not_matched_author?

    true
  end

  def not_matched_author?
    @version.user_id != @user.id
  end

  def change_fields
    if @version
      @version.item_diff.keys
    else
      [@field.to_s]
    end
  end

  def changing_restricted_fields
    @changing_restricted_fields ||= change_fields & restricted_fields
  end

  def restricted_fields
    @restricted_fields ||=
      Kernel.const_defined?("#{item_type}::RESTRICTED_FIELDS") ?
        "#{item_type}::RESTRICTED_FIELDS".constantize :
        []
  end

  def item_type
    @version ? @version.item_type : @db_entry.class.name
  end

  def restriction_change_allowed?
    # must be new ability object here otherwise
    # it will return false in runtime
    # (i.e. during Version creation in DbEntriesController)
    return true if Ability.new(@user).can?(:restricted_update, Version)

    # allow changes from nil
    changing_restricted_fields.all? do |field|
      if @version
        @version.item_diff.dig(field, 0).nil?
      else
        @db_entry.send(field).nil?
      end
    end
  end

  def name_changing?
    (
      change_fields & Abilities::VersionNamesModerator::MANAGED_FIELDS
    ).any? && Abilities::VersionNamesModerator::MANAGED_MODELS.include?(
      item_type
    )
  end
end
