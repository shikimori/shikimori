class VersionsPolicy
  static_facade :change_allowed?, :version, :user

  def change_allowed?
    return false if @user.banned?
    return false if @user.not_trusted_version_changer?
    return false if not_matched_author?

    restricted_fields = Kernel.const_defined?("#{@version.item_type}::RESTRICTED_FIELDS") ?
      "#{@version.item_type}::RESTRICTED_FIELDS".constantize :
      []
    matched_restricted_field = (@version.item_diff.keys & restricted_fields).first

    (
      # must be new ability object here otherwise
      # it will return false in runtime
      # (i.e. during Version creation in DbEntriesController)
      Ability.new(@user).can?(:restricted_update, @version) ||
      matched_restricted_field.nil? ||
      @version.item_diff.dig(matched_restricted_field, 0).nil?  # changing from nil value
    )
  end

private

  def not_matched_author?
    @version.user_id != @user.id
  end
end
