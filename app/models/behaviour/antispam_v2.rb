module AntispamV2
  extend ActiveSupport::Concern

  included do
    @antispam_options = []
  end

  module ClassMethods
    def antispam options
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
      val = create!(options)
      @antispam_enabled = true
      val
    end

    def with_antispam?
      @antispam_enabled
    end
  end

  def antispam_checks
    @antispam_options.each do |options|
      antispam_check options
    end
  end

  def antispam_check options
    return unless need_antispam_check? options

    prior_entry = self.class.where(user_id: user_id).order(id: :desc).first
    return unless prior_entry

    seconds_to_wait = ANTISPAM_INTERVAL -
      (Time.zone.now.to_i - prior_entry.created_at.to_i)
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

  def need_antispam_check? options
    self.class.with_antispam? &&
      errors.none? &&
        new_record? &&
          (!options[:disable_if] || !options[:disable_if].call())
  end
end
