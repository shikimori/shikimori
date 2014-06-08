class UserRatesController < Api::V1::UserRatesController
  def create
    @user_rate.save rescue Mysql2::Error
    render partial: 'user_rate', locals: { user_rate: @user_rate.decorate, entry: @user_rate.target }, formats: :html
  end

  def edit
  end

  def update
    @user_rate.update update_params
    render partial: 'user_rate', locals: { user_rate: @user_rate.decorate, entry: @user_rate.target }, formats: :html
  end

  def increment
    if @user_rate.anime?
      @user_rate.update episodes: @user_rate.episodes + 1
    else
      @user_rate.update chapters: @user_rate.chapters + 1
    end

    render partial: 'user_rate', locals: { user_rate: @user_rate.decorate, entry: @user_rate.target }, formats: :html
  end

  def destroy
    @user_rate.destroy!
    redirect_to @user_rate.target
  end
end
