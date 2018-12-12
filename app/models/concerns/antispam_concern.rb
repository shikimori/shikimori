module AntispamConcern
  include Translation
  extend ActiveSupport::Concern

  DAY_DURATION = 16.hours

  included do
    @antispam_options = []

    def self.inherited subclass
      super
      subclass.instance_variable_set '@antispam_enabled', @antispam_enabled
      subclass.instance_variable_set '@antispam_options', @antispam_options.dup
    end
  end

  module ClassMethods
    # antispam(
    #   interval: 1.second,
    #   per_day: 2,
    #   disable_if: -> { user.bot? },
    #   user_id_key: :user_id
    # )
    def antispam options
      @antispam_enabled = true
      @antispam_options << options

      if @antispam_options.one?
        before_create :antispam_checks
      end
    end

    def wo_antispam
      @antispam_enabled = false
      val = yield
      @antispam_enabled = true
      val
    end

    def create_wo_antispam! options
      @antispam_enabled = false
      result = create! options
      @antispam_enabled = true
      result
    end

    def antispam_enabled?
      @antispam_enabled
    end

    def antispam_options
      @antispam_options
    end
  end

  def antispam_checks
    self.class.antispam_options.each do |options|
      antispam_check options
    end
  end

  def antispam_check(
    interval: nil,
    per_day: nil,
    user_id_key:,
    disable_if: nil,
    enable_if: nil,
    scope: nil
  )
    return unless need_antispam_check? disable_if, enable_if

    per_day_check per_day, user_id_key, scope if per_day
    interval_check interval, user_id_key, scope if interval
  end

  def interval_check interval, user_id_key, apply_scope
    entry = prior_entry user_id_key, apply_scope
    return if entry.nil?

    seconds_to_wait = interval - (Time.zone.now.to_i - entry.created_at.to_i)
    return unless seconds_to_wait.positive?

    errors.add(
      :base,
      I18n.t(
        'message.antispam.interval',
        interval: seconds_to_wait,
        seconds: i18n_i('datetime.second', seconds_to_wait, :accusative)
      )
    )
    throw :abort
  end

  def per_day_check per_day, user_id_key, apply_scope
    entries_count = daily_entries_count user_id_key, apply_scope
    return if entries_count < per_day

    errors.add :base, I18n.t('message.antispam.per_day')
    throw :abort
  end

  def prior_entry user_id_key, apply_scope
    scope = self.class.base_class.order id: :desc
    scope = scope.instance_exec(&apply_scope) if apply_scope
    scope.find_by user_id_key => send(user_id_key)
  end

  def daily_entries_count user_id_key, apply_scope
    scope = self.class.base_class
      .where(user_id_key => send(user_id_key))
      .where('created_at >= ?', DAY_DURATION.ago)
    scope = scope.instance_exec(&apply_scope) if apply_scope
    scope.count
  end

  def disable_antispam!
    @instance_antispam_disabled = true
  end

  def antispam_enabled?
    self.class.antispam_enabled? && !@instance_antispam_disabled
  end

  def need_antispam_check? disable_if, enable_if # rubocop:disable CyclomaticComplexity
    antispam_enabled? &&
      errors.none? &&
      new_record? &&
      (!disable_if || !instance_exec(&disable_if)) &&
      (!enable_if || instance_exec(&enable_if))
  end
end
