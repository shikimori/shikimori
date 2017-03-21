# TODO: переделать авторизацию на cancancan
class Moderations::UsersController < ModerationsController
  def index
    noindex && nofollow
    page_title i18n_t('page_title')

    params[:created_on] ||= Time.zone.today.to_s

    @collection = User
      .where(
        'created_at >= ? and created_at <= ?',
        Time.zone.parse(params[:created_on]).beginning_of_day,
        Time.zone.parse(params[:created_on]).end_of_day
      )
      .order(:created_at)
  end
end
