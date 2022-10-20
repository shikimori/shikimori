class Api::V1::UserRatesController < Api::V1Controller
  load_and_authorize_resource

  CREATE_PARAMS = %i[
    target_id target_type user_id status episodes chapters volumes score text
    rewatches
  ]
  UPDATE_PARAMS = %i[status episodes chapters volumes score text rewatches]

  UNIQ_EXCEPTIONS = [ActiveRecord::RecordNotUnique, PG::UniqueViolation]
  ALLOWED_EXCEPTIONS = [PG::Error, RangeError, NotSaved]

  RatesType = Types::Strict::Symbol
    .constructor { |v| "#{v}_rates".to_sym }
    .enum(:anime_rates, :manga_rates)

  before_action except: %i[show] do
    doorkeeper_authorize! :user_rates if doorkeeper_token.present?
  end

  api :GET, '/user_rates/:id', 'Show an user rate', deprecated: true
  def show
    respond_with @resource
  end

  api :POST, '/user_rates', 'Create an user rate', deprecated: true
  description 'Requires `user_rates` oauth scope'
  param :user_rate, Hash do
    param :user_id, :number, required: true
    param :target_id, :number, required: true
    param :target_type, %w[Anime Manga], required: true
    param :status, :undef, required: true
    # param :status, UserRate.statuses.keys, required: true
    param :score, :undef, required: false, allow_blank: true
    param :chapters, :undef, required: false, allow_blank: true
    param :episodes, :undef, required: false, allow_blank: true
    param :volumes, :undef, required: false, allow_blank: true
    param :rewatches, :undef, required: false, allow_blank: true
    param :text, String, required: false, allow_blank: true
  end
  def create
    Retryable.retryable tries: 2, on: UNIQ_EXCEPTIONS, sleep: 1 do
      present_rate = UserRate.find_by(
        user_id: @resource.user_id,
        target_id: @resource.target_id,
        target_type: @resource.target_type
      )

      if present_rate
        update_rate present_rate
      else
        create_rate @resource
      end
    end

    respond_with @resource, location: nil, serializer: UserRateFullSerializer
  end

  api :PATCH, '/user_rates/:id', 'Update an user rate', deprecated: true
  api :PUT, '/user_rates/:id', 'Update an user rate', deprecated: true
  description 'Requires `user_rates` oauth scope'
  param :user_rate, Hash do
    param :status, :undef, required: false
    # param :status, UserRate.statuses.keys, required: true
    param :score, :undef, required: false, allow_blank: true
    param :chapters, :undef, required: false, allow_blank: true
    param :episodes, :undef, required: false, allow_blank: true
    param :volumes, :undef, required: false, allow_blank: true
    param :rewatches, :undef, required: false, allow_blank: true
    param :text, String, required: false, allow_blank: true
  end
  def update
    update_rate @resource
    respond_with @resource, location: nil, serializer: UserRateFullSerializer
  end

  api :POST, '/user_rates/:id/increment', 'Increment episodes/chapters by 1',
    deprecated: true
  description 'Requires `user_rates` oauth scope'
  def increment
    @resource.update increment_params
    log @resource

    if @resource.anime?
      Achievements::Track.perform_async(
        @resource.user_id,
        @resource.id,
        Types::Neko::Action[:put]
      )
    end
    respond_with @resource, location: nil, serializer: UserRateFullSerializer
  end

  api :DELETE, '/user_rates/:id', 'Destroy an user rate', deprecated: true
  description 'Requires `user_rates` oauth scope'
  def destroy
    @resource.destroy!
    log @resource

    if @resource.anime?
      Achievements::Track.perform_async(
        @resource.user_id,
        @resource.id,
        Types::Neko::Action[:delete]
      )
    end

    head :no_content
  end

  api :DELETE, '/user_rates/:type/cleanup', 'Delete entire user rates and history'
  description 'Requires `user_rates` oauth scope'
  param :type, %w[anime manga], required: true
  def cleanup # rubocop:disable AbcSize, MethodLength
    user = current_user.object

    user.history
      .where.not((params[:type].capitalize == 'Anime' ? :anime_id : :manga_id) => nil)
      .delete_all
    user.history.where(action: "#{params[:type]}_import").delete_all
    user.history.where(action: "mal_#{params[:type]}_import").delete_all
    user.history.where(action: "ap_#{params[:type]}_import").delete_all
    user.send(RatesType[params[:type]]).delete_all
    user.touch

    if params[:type] == 'anime'
      Achievements::Track.perform_async(
        user.id,
        nil,
        Types::Neko::Action[:reset]
      )
    end

    render json: { notice: i18n_t("list_and_history_cleared.#{params[:type]}") }
  end

  api :DELETE, '/user_rates/:type/reset', 'Reset all user scores to 0'
  description 'Requires `user_rates` oauth scope'
  param :type, %w[anime manga], required: true
  def reset
    user = current_user.object

    user.send(RatesType[params[:type]]).update_all score: 0
    user.touch

    if params[:type] == 'anime'
      Achievements::Track.perform_async(
        user.id,
        nil,
        Types::Neko::Action[:reset]
      )
    end

    render json: { notice: i18n_t("scores_reset.#{params[:type]}") }
  end

private

  def create_params
    params
      .require(:user_rate)
      .permit(*CREATE_PARAMS)
  end

  def update_params
    params
      .require(:user_rate)
      .permit(*UPDATE_PARAMS)
  end

  def increment_params
    if @resource.anime?
      { episodes: (params[:episodes] || @resource.episodes) + 1 }
    else
      { chapters: (params[:chapters] || @resource.chapters) + 1 }
    end
  end

  def create_rate user_rate
    @resource = user_rate
    raise NotSaved unless @resource.save

    log @resource

    if @resource.anime?
      Achievements::Track.perform_async(
        @resource.user_id,
        @resource.id,
        Types::Neko::Action[:put]
      )
    end
  rescue *ALLOWED_EXCEPTIONS
  end

  def update_rate user_rate
    @resource = user_rate
    raise NotSaved unless @resource.update update_params

    log @resource

    if @resource.anime?
      Achievements::Track.perform_async(
        @resource.user_id,
        @resource.id,
        Types::Neko::Action[:put]
      )
    end
  rescue *ALLOWED_EXCEPTIONS
  end

  def log user_rate
    UserRates::Log.call(
      user_rate: user_rate,
      ip: request.remote_ip,
      user_agent: request.user_agent,
      oauth_application_id: doorkeeper_token&.application_id
    )
  end
end
