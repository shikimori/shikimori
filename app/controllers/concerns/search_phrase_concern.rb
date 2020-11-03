module SearchPhraseConcern
  extend ActiveSupport::Concern

  included do
    helper_method :search_russian?
  end

  def search_phrase
    params[:search] || params[:q]
  end

  def search_russian?
    search_phrase.contains_russian? if search_phrase.present?
  end
end
