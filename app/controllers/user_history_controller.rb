class UserHistoryController < ProfilesController
  ENTRIES_PER_PAGE = 90

  def index
    redirect_to @resource.url unless @resource.history.any?
    authorize! :access_list, @resource

    @page = (params[:page] || 1).to_i
    @collection, @add_postloader =
      UserHistoryQuery.new(@resource).postload(@page, ENTRIES_PER_PAGE)

    page_title 'История'
  end


  def reset
    authorize! :edit, @resource

    @resource.object.history.where(target_type: params[:type].capitalize).delete_all
    @resource.object.history.where(action: "mal_#{params[:type]}_import").delete_all
    @resource.object.history.where(action: "ap_#{params[:type]}_import").delete_all
    @resource.touch

    render json: { notice: "Выполнена очистка вашей истории по #{params[:type] == 'anime' ? 'аниме' : 'манге'}" }
  end
end
