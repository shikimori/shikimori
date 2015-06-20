class AchievementsController < ProfilesController
  before_action :additional_breadcrumbs, except: [:index]
  page_title 'Достижения'

  def index
  end

  def franchise
    page_title 'Франшизы'
  end

private

  def additional_breadcrumbs
    @back_url = profile_achievements_url(@resource)
    breadcrumb 'Достижения', @back_url
  end
end
