module CensoredConcern
  extend ActiveSupport::Concern

  FORBIDDEN_EVERYWHERE_PATHS = %w[
    /animes/z1535-death-note
  ]
  FORBIDDEN_SHIKIMORI_ME_PATHS = []

  included do
    before_action :ensure_404_on_forbidden_urls
  end

  def ensure_404_on_forbidden_urls
    is_forbidden =
      FORBIDDEN_EVERYWHERE_PATHS.any? { |path| request.path.starts_with? path } || (
        old_host? &&
          FORBIDDEN_SHIKIMORI_ME_PATHS.any? { |path| request.path.starts_with? path }
      )

    raise ActiveRecord::RecordNotFound if is_forbidden
  end
end
