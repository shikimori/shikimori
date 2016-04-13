class UserHistoryController < ProfilesController
  def index
    noindex
    redirect_to @resource.url unless @resource.history.any?
    authorize! :access_list, @resource

    @view = UserHistoryView.new @resource

    page_title 'История'
  end

  def reset
    authorize! :edit, @resource

    @resource.object.history.where(target_type: params[:type].capitalize).delete_all
    @resource.object.history
      .where(action: [
        "mal_#{params[:type]}_import",
        "ap_#{params[:type]}_import",
        clear_action
      ]).delete_all
    @resource.object.history.create! action: clear_action
    @resource.touch

    render json: { notice: "Выполнена очистка вашей истории по #{anime? ? 'аниме' : 'манге'}" }
  end

private

  def anime?
    params[:type] == 'anime'
  end

  def clear_action
    if anime?
      UserHistoryAction::AnimeHistoryClear
    else
      UserHistoryAction::MangaHistoryClear
    end
  end
end
