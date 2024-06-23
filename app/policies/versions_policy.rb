class VersionsPolicy
  RESTRICTED_EMPTY_CHANGE_NOT_ALLOWED = %w[genres_v2]

  def self.version_allowed? user, version
    new(user, version:).call
  end

  def self.change_allowed? user, db_entry, field
    new(user, db_entry:, field:).call
  end

  def initialize user, version: nil, db_entry: nil, field: nil
    @user = user
    @version = version

    if db_entry
      @db_entry = db_entry.respond_to?(:decorated?) && db_entry.decorated? ?
        db_entry.object :
        db_entry
    end

    unless field.nil?
      @field = field.to_s
    end
  end

  def call
    return false unless allowed?

    if changing_restricted_fields.any?
      restriction_change_allowed?
    else
      true
    end
  end
  alias change_allowed? call
  alias version_allowed? call

  def restricted_fields
    @restricted_fields ||=
      Kernel.const_defined?("#{item_type}::RESTRICTED_FIELDS") ?
        "#{item_type}::RESTRICTED_FIELDS".constantize :
        []
  end

private

  # rubocop:disable all
  def allowed?
    if !@user
      false
    elsif @user.banned?
      false
    elsif @user.not_trusted_version_changer?
      false
    elsif @user.not_trusted_names_changer? && field_changing?(Abilities::VersionNamesModerator)
      false
    elsif @user.not_trusted_texts_changer? && field_changing?(Abilities::VersionTextsModerator)
      false
    elsif @user.not_trusted_fansub_changer? && field_changing?(Abilities::VersionFansubModerator)
      false
    elsif @user.not_trusted_videos_changer? && field_changing?(Abilities::VersionVideosModerator)
      false
    elsif @user.not_trusted_images_changer? && field_changing?(Abilities::VersionImagesModerator)
      false
    elsif @user.not_trusted_links_changer? && field_changing?(Abilities::VersionLinksModerator)
      false
    elsif @version && not_matched_author?
      false
    else
      true
    end
  end
  # rubocop:enable all

  def not_matched_author?
    @version.user_id != @user.id
  end

  def change_fields
    if @version
      @version.item_diff.keys
    else
      [@field]
    end
  end

  def changing_restricted_fields
    @changing_restricted_fields ||= change_fields & restricted_fields
  end

  def item_type
    @version ? @version.item_type : @db_entry.class.name
  end

  def restriction_change_allowed?
    # must be new ability object here otherwise
    # it will return false in runtime
    # (i.e. during Version creation in DbEntriesController)
    return true if Ability.new(@user).can?(:restricted_update, version_or_double)

    # allow changes from nil
    changing_restricted_fields.all? do |field|
      if field.in? RESTRICTED_EMPTY_CHANGE_NOT_ALLOWED
        false
      elsif @version
        @version.item_diff.dig(field, 0).nil?
      else
        @db_entry.send(field).nil? || @db_entry.send(field).blank? # blank check for image fields
      end
    end
  end

  def field_changing? ability_klass
    (
      (
        change_fields & ability_klass::MANAGED_FIELDS
      ).any? && ability_klass::MANAGED_FIELDS_MODELS.include?(
        item_type
      )
    ) || ability_klass::MANAGED_MODELS.include?(item_type)
  end

  def version_or_double
    @version_or_double ||= @version ||
      Version.new(item: @db_entry, item_diff: { @field => [1, 2] })
  end
end
