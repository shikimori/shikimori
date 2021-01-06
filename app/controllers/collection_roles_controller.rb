class CollectionRolesController < ShikimoriController
  load_and_authorize_resource

  def create
    @resource.save!

    redirect_to edit_collection_url(@resource.collection),
      notice: i18n_t(
        '.you_have_added_coauthor',
        coauthor: @resource.user.nickname,
        gender: current_user.sex
      )
  end

  def destroy
    @resource.destroy!

    redirect_to edit_collection_url(@resource.collection),
      notice: i18n_t(
        '.you_have_removed_coauthor',
        coauthor: @resource.user.nickname,
        gender: current_user.sex
      )
  end

private

  def collection_role_params
    params.require(:collection_role).permit(%i[collection_id user_id])
  end
end
