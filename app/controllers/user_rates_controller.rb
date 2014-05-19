class UserRatesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :fetch_rate

  # добавление аниме в свой список
  def create
    @rate = UserRate.create_or_find current_user.id, params[:id], params[:type]

    if @rate.save
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
    end

    render json: { notice: params[:type] == 'Anime' ? 'Аниме удалено из списка' : 'Манга удалена из списка' }
  end

  # изменение аниме в своем списке
  def update
    return render json: {} unless @rate

    @rate.update user_rate_params

    if @rate.errors.empty?
      render json: {
        status: @rate.status,
        episodes: @rate.episodes,
        volumes: @rate.volumes,
        chapters: @rate.chapters,
        score: @rate.score,
        text_html: @rate.text_html
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
    params[:user_rate][:status] = params[:user_rate][:status].to_i if params[:user_rate][:status]
    params.require(:user_rate).permit(:status, :episodes, :chapters, :volumes, :score, :text)
  end
end
