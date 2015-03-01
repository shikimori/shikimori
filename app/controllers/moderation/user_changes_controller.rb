# TODO: переделать авторизацию на cancancan
class Moderation::UserChangesController < ShikimoriController
  include ActionView::Helpers::SanitizeHelper
  before_filter :authenticate_user!, only: [:index, :take, :deny]
  PENDING_PER_PAGE = 40

  page_title 'Правки пользователей'

  def show
    noindex
    @resource = UserChange.find(params[:id])
    page_title "Правка ##{@resource.id} от пользователя #{@resource.user.nickname}"
  end

  def tooltip
    noindex
    @resource = UserChange.find(params[:id])
  end

  # отображение списка предложенных пользователями изменений
  def index
    raise Forbidden unless current_user.user_changes_moderator?

    @processed = postload_paginate(params[:page], 25) do
      UserChange
        .includes(:user)
        .includes(:approver)
        .where.not(status: [UserChangeStatus::Pending])
        .order(updated_at: :desc)
    end

    unless request.xhr?
      @page_title = 'Правки пользователей'
      @pending = UserChange
        .includes(:user)
        .where(status: UserChangeStatus::Pending)
        .order("(case when \"column\"='tags' then 0 when \"column\"='screenshots' then 1 when \"column\"='video' then 2 else 3 end), created_at")
        .limit(PENDING_PER_PAGE)
        .to_a

      @changes_map = {}
      # по конкретному элементу делаем только одно активное изменение
      @pending.each do |change|
        key = "#{change.model} #{change.item_id}"
        if @changes_map[key]
          def change.locked; true; end
        elsif change.screenshots?
          @changes_map[key] = true
        end
      end

      @moderators = User.where(id: User::UserChangesModerators - User::Admins).sort_by { |v| v.nickname.downcase }
    end
  end

  # изменение пользователем чего-либо
  def create
    @resource = UserChange.new user_change_params.merge(user_id: current_user.try(:id) || User::GuestID)

    if @resource.value == @resource.current_value && @resource.source == @resource.item.source
      return redirect_to_back_or_to @resource.item, alert: 'Нет изменений'
    end

    if @resource.save
      if params[:apply] && current_user && current_user.user_changes_moderator?
        @resource.apply current_user.id, true
        notice = 'Правка применена'
      else
        notice = 'Правка сохранена и будет в ближайшее время рассмотрена модератором. Домо аригато.'
      end

      redirect_to_back_or_to @resource.item, notice: notice
    else
      render text: 'Произошла ошибка при создании правки. Пожалуйста, напишите об этом администратору.', status: :unprocessable_entity
    end
  end

  # применение предложенного пользователем изменения
  def take
    raise Forbidden unless current_user.user_changes_moderator?
    @resource = UserChange.find(params[:id])

    if @resource.apply current_user.id, !params[:is_applied]
      Message.create(
        from_id: current_user.id,
        to_id: @resource.user_id,
        kind: MessageType::Notification,
        body: "Ваша [user_change=#{@resource.id}]правка[/user_change] для [#{@resource.item.class.name.downcase}]#{@resource.item.id}[/#{@resource.item.class.name.downcase}] принята."
      ) unless @resource.user_id == current_user.id

      redirect_to_back_or_to moderation_user_changes_url, notice: 'Правка успешно применена'
    else
      render text: "Произошла ошибка при принятии правки. Номер правки ##{@resource.id}. Пожалуйста, напишите об этом администратору.", status: :unprocessable_entity
    end
  end

  # отказ предложенного пользователем изменения
  def deny
    @resource = UserChange.find params[:id]
    raise Forbidden unless current_user.user_changes_moderator? || current_user.id == @resource.user_id

    if @resource.deny(current_user.id, params[:is_deleted])
      if !params[:is_deleted] && @resource.user_id != current_user.id
        Message.create(
          from_id: current_user.id,
          to_id: @resource.user_id,
          kind: MessageType::Notification,
          body: "Ваша [user_change=#{@resource.id}]правка[/user_change] для [#{@resource.item.class.name.downcase}]#{@resource.item.id}[/#{@resource.item.class.name.downcase}] отклонена."
        )
      end

      redirect_to_back_or_to moderation_user_changes_url
    else
      render text: "Произошла ошибка при отказе правки. Номер правки ##{@resource.id}. Пожалуйста, напишите об этом администратору.", status: :unprocessable_entity
    end
  end

private
  def user_change_params
    params
      .require(:user_change)
      .permit(:model, :column, :item_id, :value, :source, :action)
  end
end
