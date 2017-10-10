class AchievementsController < ShikimoriController
  before_action do
    page_title i18n_i('Achievement', :other)
  end

  def index
  end

  def show
    @collection = Neko::Repository.instance
      .select { |v| v[:neko_id] == params[:id].to_sym }
      .sort_by(&:sort_criteria)

    page_title(
      "#{i18n_i 'Achievement', :one} \"#{@collection.first.neko_name}\""
    )
    breadcrumb i18n_i('Achievement', :other), achievements_url
  end
end
