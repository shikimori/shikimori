# refactor to models/concerns
module Antispam
  include Translation
  extend ActiveSupport::Concern

  included do
    before_create :check_antispam
    @antispam = true
  end

  ANTISPAM_INTERVAL = 3.seconds

  module ClassMethods
    attr_accessor :antispam

    def wo_antispam
      @antispam = false
      val = yield
      @antispam = true
      val
    end

    def create_wo_antispam! options
      @antispam = false
      val = create!(options)
      @antispam = true
      val
    end

    def with_antispam?
      @antispam
    end
  end

  def with_antispam?
    self.class.with_antispam?
  end

  def check_antispam # rubocop:disable MethodLength, AbcSize
    return unless need_antispam_check?

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

  def need_antispam_check?
    return false if id # it's editing if we have 'id'
    return false unless with_antispam?

    !user.admin? && !user.bot?
  end
end
