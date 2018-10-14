module Antispam
  include Translation
  extend ActiveSupport::Concern

  included do
    @antispam_options = []

    def self.inherited subclass
      subclass.instance_variable_set '@antispam_options', @antispam_options.clone
    end
  end

  module ClassMethods
    # antispam(
    #   interval: 1.second,
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

  def antispam_check interval:, user_id_key:, disable_if: nil
    return unless need_antispam_check? disable_if
    entry = prior_entry(user_id_key) || return

    seconds_to_wait = interval - (Time.zone.now.to_i - entry.created_at.to_i)
    return unless seconds_to_wait.positive?

    errors.add(
      :base,
      I18n.t(
        'message.antispam',
        interval: seconds_to_wait,
        seconds: i18n_i('datetime.second', seconds_to_wait, :accusative)
      )
    )
    throw :abort
  end

  def prior_entry user_id_key
    self.class
      .order(id: :desc)
      .find_by(user_id_key => send(user_id_key))
  end

  def disable_antispam!
    @instance_antispam_disabled = true
  end

  def antispam_enabled?
    self.class.antispam_enabled? && !@instance_antispam_disabled
  end

  def need_antispam_check? disable_if
    antispam_enabled? &&
      errors.none? &&
        new_record? &&
          (!disable_if || !instance_exec(&disable_if))
  end
end
