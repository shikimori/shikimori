class Moderation::VersionsController < ShikimoriController
  load_and_authorize_resource

  page_title i18n_t('content_changes')

  def show
    noindex
    page_title i18n_t('content_change', version_id: @resource.id, author: @resource.user.nickname)
  end

  def tooltip
    noindex
  end

  def index
    raise Forbidden unless current_user.user_changes_moderator?
    @versions = VersionsView.new
  end

  # применение предложенного пользователем изменения
  def accept
    @resource.accept current_user
    redirect_to_back_or_to moderation_versions_url, notice: i18n_t('changes_accepted')
  end

  def take
    @resource.take current_user
    redirect_to_back_or_to moderation_versions_url, notice: i18n_t('changes_accepted')
  end

  def reject
    @resource.reject current_user, params[:reason]
    redirect_to_back_or_to moderation_versions_url, notice: i18n_t('changes_rejected')
  end

  def destroy
    @resource.to_deleted current_user
    redirect_to_back_or_to moderation_versions_url, notice: i18n_t('changes_deleted')
  end

  #def take
    #raise Forbidden unless current_user.user_changes_moderator?
    #@resource = UserChange.find(params[:id])

    #if @resource.apply current_user.id, !params[:is_applied]
      #Message.create_wo_antispam!(
        #from_id: current_user.id,
        #to_id: @resource.user_id,
        #kind: MessageType::Notification,
        #body: "Ваша [user_change=#{@resource.id}]правка[/user_change] для [#{@resource.item.class.name.downcase}]#{@resource.item.id}[/#{@resource.item.class.name.downcase}] принята."
      #) unless @resource.user_id == current_user.id

      #redirect_to_back_or_to moderation_user_changes_url, notice: 'Правка успешно применена'
    #else
      #render text: "Произошла ошибка при принятии правки. Номер правки ##{@resource.id}. Пожалуйста, напишите об этом администратору.", status: :unprocessable_entity
    #end
  #end

  ## отказ предложенного пользователем изменения
  #def deny
    #@resource = UserChange.find params[:id]
    #raise Forbidden unless current_user.user_changes_moderator? || current_user.id == @resource.user_id

    #if @resource.deny current_user.id, params[:is_deleted]
      #type = @resource.item.class.name.downcase
      #Message.create_wo_antispam!(
        #from_id: current_user.id,
        #to_id: @resource.user_id,
        #kind: MessageType::Notification,
        #body: "Ваша [user_change=#{@resource.id}]правка[/user_change] для " +
          #"[#{type}]#{@resource.item.id}[/#{type}] отклонена" +
          #(params[:reason].present? ?
            #" по причине: [quote=#{current_user.nickname}]#{params[:reason]}[/quote]" : '.')
      #) if !params[:is_deleted] && @resource.user_id != current_user.id

      #redirect_to_back_or_to moderation_user_changes_url
    #else
      #render text: "Произошла ошибка при отказе правки. Номер правки ##{@resource.id}. Пожалуйста, напишите об этом администратору.", status: :unprocessable_entity
    #end
  #end
end
