class UserRatesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :fetch_rate

  # очистка списка и истории
  def cleanup
    raise Forbidden unless ['anime', 'manga'].include? params[:type]

    current_user.object.history.where(target_type: params[:type].capitalize).delete_all
    current_user.object.history.where(action: "mal_#{params[:type]}_import").delete_all
    current_user.object.history.where(action: "ap_#{params[:type]}_import").delete_all
    current_user.send("#{params[:type]}_rates").delete_all
    current_user.touch

    flash[:notice] = "Выполнена очистка вашего #{params[:type] == 'anime' ? 'аниме' : 'манги'} списка и вашей истории по #{params[:type] == 'anime' ? 'аниме' : 'манге'}"
    redirect_to user_url(current_user)
  end

  # сброс оценок в списке
  def reset
    raise Forbidden unless ['anime', 'manga'].include? params[:type]

    current_user.send("#{params[:type]}_rates").update_all score: 0
    current_user.touch

    flash[:notice] = "Выполнен сброс оценок в вашем #{params[:type] == 'anime' ? 'аниме' : 'манги'} списке"
    redirect_to user_url(current_user)
  end

  # добавление аниме в свой список
  def create
    @rate = UserRate.find_by(user_id: current_user.id, target_id: params[:id], target_type: params[:type]) ||
      UserRate.create(user_id: current_user.id, target_id: params[:id], target_type: params[:type], status: UserRateStatus.default)

    if @rate.save
      UserHistory.add current_user, @rate.target, UserHistoryAction::Add

      render json: {
        status: @rate.status,
        episodes: @rate.episodes,
        volumes: @rate.volumes,
        chapters: @rate.chapters,
        rate_content: render_to_string({
          partial: 'ani_mangas/rate',
          layout: false,
          locals: { key: 'user', value: '' }
        }, formats: :html)
      }
    else
      render json: @rate.errors, status: :unprocessable_entity
    end

  rescue ActiveRecord::RecordNotUnique
    @tries ||= 2
    unless (@tries -= 1).zero?
      retry
    else
      raise
    end
  end

  # удаление аниме из своего списка
  def destroy
    if @rate.present?
      @rate.destroy
      UserHistory.add(current_user, @rate.target, UserHistoryAction::Delete)
    end

    render json: { notice: params[:type] == 'Anime' ? 'Аниме удалено из списка' : 'Манга удалена из списка' }
  end

  # изменение аниме в своем списке
  def update
    return render json: {} unless @rate

    @rate.update_notice user_rate_params[:notice] if user_rate_params[:notice]
    [:episodes, :volumes, :chapters, :score, :status].each do |key|
      next unless user_rate_params[key]
      value = user_rate_params[key].to_i
      @rate.send "update_#{key}", value if @rate[key] != value
    end

    if @rate.errors.empty?
      render json: {
        status: @rate.status,
        episodes: @rate.episodes,
        volumes: @rate.volumes,
        chapters: @rate.chapters,
        score: @rate.score,
        notice_html: @rate.notice_html
      }
    else
      render json: @rate.errors, status: :unprocessable_entity
    end
  end

private
  def fetch_rate
    @rate = UserRate.find_by_user_id_and_target_id_and_target_type(current_user.id, params[:id], params[:type]) if params[:id]
  end

  def user_rate_params
    params[:user_rate] ||= params[:rate]
    params.require(:user_rate).permit(:status, :episodes, :chapters, :volumes, :score, :notice)
  end
end
