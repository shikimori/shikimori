module CensoredConcern
  extend ActiveSupport::Concern

  FORBIDDEN_EVERYWHERE_PATHS = %w[
    /animes/z1535-death-note
  ]
  FORBIDDEN_SHIKIMORI_ONE_PATHS = %w[
    /animes/1535-death-note
  ]

  included do
    before_action :ensure_404_on_forbidden_urls
  end

  def ensure_404_on_forbidden_urls
    is_forbidden =
      FORBIDDEN_EVERYWHERE_PATHS.any? { |v| v.starts_with? request.path } || (
        old_host? &&
          FORBIDDEN_SHIKIMORI_ONE_PATHS.any? { |v| v.starts_with? request.path }
      )

    raise ActiveRecord::RecordNotFound if is_forbidden
  end
end
