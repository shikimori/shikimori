class VersionsPolicy
  pattr_initialize :user, %i[version item field]

  def self.version_allowed? user, version
    new(user, version: version).call
  end

  def call
    return false if @user.banned?
    return false if @user.not_trusted_version_changer?
    return false if @user.not_trusted_names_changer? && name_changed?
    return false if not_matched_author?

    if changed_restricted_fields.any?
      restriction_change_allowed?
    else
      true
    end
  end

private

  def not_matched_author?
    @version.user_id != @user.id
  end

  def changed_restricted_fields
    @changed_restricted_fields ||= @version.item_diff.keys & restricted_fields
  end

  def restricted_fields
    @restricted_fields ||=
      Kernel.const_defined?("#{@version.item_type}::RESTRICTED_FIELDS") ?
        "#{@version.item_type}::RESTRICTED_FIELDS".constantize :
        []
  end

  def restriction_change_allowed?
    # must be new ability object here otherwise
    # it will return false in runtime
    # (i.e. during Version creation in DbEntriesController)
    return true if Ability.new(@user).can?(:restricted_update, @version)

    # allow changes from nil
    changed_restricted_fields.all? do |field|
      @version.item_diff.dig(field, 0).nil?
    end
  end

  def name_changed?
    (
      @version.item_diff.keys & Abilities::VersionNamesModerator::MANAGED_FIELDS
    ).any? && Abilities::VersionNamesModerator::MANAGED_MODELS.include?(
      version.item_type
    )
  end
end
