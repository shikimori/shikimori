class Moderation::UserChangesController < ApplicationController
  include ActionView::Helpers::SanitizeHelper
  before_filter :authenticate_user!, only: [:index, :apply, :deny, :get_anime_lock, :release_anime_lock]

  # отображение одной правки
  def show
    set_meta_tags noindex: true, nofollow: true

    @entry = UserChange.includes(:user).find(params[:id])
    @page_title = [
      'Правки пользователей',
      "Правка ##{@entry.id} пользователя #{@entry.user.nickname}"
    ]
  end

  # тултип о правке
  def tooltip
    show
    render 'blocks/tooltip', layout: params.include?('test')
  end

  # отображение списка предложенных пользователями изменений
  def index
    raise Forbidden unless current_user.user_changes_moderator?

    @processed = postload_paginate(params[:page], 25) do
      UserChange
        .includes(:user)
        .includes(:approver)
        .where { status.not_in([UserChangeStatus::Pending, UserChangeStatus::Locked]) }
        .order { updated_at.desc }
    end

    render json: {
      content: render_to_string({
        partial: 'site/editor_changes',
        layout: false,
        locals: { changes: @processed, moderation: true },
        formats: :html
      }) + (@add_postloader ?
        render_to_string(partial: 'site/postloader_new', locals: { url: moderation_users_changes_url(page: @page+1) }, formats: :html) :
        '')
    } and return if json?

    @page_title = 'Правки пользователей'
    @pending = UserChange.includes(:user)
                         .where(status: UserChangeStatus::Pending)
                         .order(:created_at)
                         .all

    @changes_map = {}
    # по конкретному элементу делаем только одно активное изменение
    @pending.each do |change|
      key = "#{change.model} #{change.item_id}"
      if @changes_map[key]
        change[:locked] = true
      elsif change.screenshots?
        @changes_map[key] = true
      end
    end

    @moderators = User.where(id: User::UserChangesModerators - User::Admins).all.sort_by { |v| v.nickname.downcase }
  end

  # изменение пользователем чего-либо
  def change
    user = current_user
    unless user_signed_in?
      # теги можно и гостям задавать
      if params[:change]['column'] == 'tags'
        user = User.find(User::GuestID)
      else
        raise Unauthorized
      end
    end
    #raise Forbidden unless UserChange.where(model: params[:change]['model'],
                                            #item_id: params[:change]['item_id'],
                                            #:user_id.not_eq => user.id,
                                            #status: UserChangeStatus::Locked).count == 0
    change = UserChange.new user_change_params
    change.user_id = user.id

    if change.value == change.current_value
      unless (change.source.present? || change.item.source.present?) && change.source != change.item.source
        if params[:apply].present?
          flash[:alert] = 'Нет никаких изменений'
          redirect_to :back
        else
          render json: ['Нет никаких изменений'], status: :unprocessable_entity
        end
        return
      end
    end

    if change.save
      # сразу же применение изменений при apply
      if params[:apply].present?
        params[:id] = change.id
        params[:taken] = true
        return apply
      end

      render json: {}
    else
      render json: change.errors, status: :unprocessable_entity
    end
  end

  # применение предложенного пользователем изменения
  def apply
    raise Forbidden unless current_user.user_changes_moderator?
    change = UserChange.find(params[:id])

    if change.apply(current_user.id, params[:taken])
      Message.create({
        src_type: User.name,
        src_id: current_user.id,
        dst_type: User.name,
        dst_id: change.user_id,
        kind: MessageType::Notification,
        body: "Ваша [user_change=#{change.id}]правка[/user_change] для [#{change.item.class.name.downcase}]#{change.item.id}[/#{change.item.class.name.downcase}] принята."
      }) unless change.user_id == current_user.id

      redirect_to_back_or_to moderation_users_changes_url, notice: 'Правка успешно применена'
    else
      render text: "Произошла ошибка при принятии правки. Номер правки ##{change.id}. Пожалуйста, напишите об этом администратору.", status: :unprocessable_entity
    end
  end

  # отказ предложенного пользователем изменения
  def deny
    change = UserChange.find params[:id]
    raise Forbidden unless current_user.user_changes_moderator? || current_user.id == change.user_id

    if change.deny(current_user.id, params[:notify])
      if params[:notify]
        Message.create({
          src_type: User.name,
          src_id: current_user.id,
          dst_type: User.name,
          dst_id: change.user_id,
          kind: MessageType::Notification,
          body: "Ваша [user_change=#{change.id}]правка[/user_change] для [#{change.item.class.name.downcase}]#{change.item.id}[/#{change.item.class.name.downcase}] отклонена."
        }) unless change.user_id == current_user.id
      end

      redirect_to :back
    else
      render json: change.errors, status: :unprocessable_entity
    end
  end

  # забрать аниме на перевод
  def get_anime_lock
    unless Group.find(Group::TranslatorsID).has_member?(current_user)
      render json: ['Только участники группы переводов могут забирать аниме на перевод'], status: :unprocessable_entity
      return
    end
    anime = Anime.find(params[:anime_id])

    can_be_locked = UserChange.where(status: [UserChangeStatus::Locked, UserChangeStatus::Pending, UserChangeStatus::Accepted], item_id: anime, model: Anime.name).count == 0
    raise Forbidden unless can_be_locked

    if UserChange.where(status: UserChangeStatus::Locked, user_id: current_user.id).count > 4
      render json: ['Нельзя забрать на перевод более четырёх аниме'], status: :unprocessable_entity
    else
      UserChange.create!(user_id: current_user.id, item_id: anime.id, model: Anime.name, status: UserChangeStatus::Locked)
      render json: {
        success: true,
        notice: '%s забрано на перевод' % anime.name,
        html: render_to_string(partial: 'translation/lock', locals: {
          anime: anime,
          changes: TranslationController.pending_animes,
          locks: TranslationController.locked_animes
        }, formats: :html)
      }
    end
  end

  # отменить право на перевод аниме
  def release_anime_lock
    anime = Anime.find(params[:anime_id])

    lock = UserChange.where(status: UserChangeStatus::Locked, user_id: current_user.id, item_id: anime, model: Anime.name).first
    can_be_unlocked = current_user.admin? || lock != nil
    raise Forbidden unless can_be_unlocked
    lock.destroy

    render json: {
      success: true,
      notice: 'Перевод %s отменен' % anime.name,
      html: render_to_string(partial: 'translation/lock', locals: {
        anime: anime,
        changes: TranslationController.pending_animes,
        locks: TranslationController.locked_animes
      }, formats: :html)
    }
  end

private
  def user_change_params
    params
      .require(:change)
      .permit(:model, :column, :item_id, :value, :source)
  end
end
