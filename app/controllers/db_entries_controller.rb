class DbEntriesController < ShikimoriController
  before_action :authenticate_user!, only: [:edit, :edit_field, :update]

  def tooltip
    noindex
  end

  def versions
    render template: 'db_entries/versions'
  end

  def edit
    noindex
    page_title i18n_t('entry_edit')
  end

  def edit_field
    noindex
    @field = params[:field]

    # TODO: удалить после выпиливания UserChange
    @user_change = UserChange.new(
      model: @resource.object.class.name,
      item_id: @resource.id,
      column: @page,
      source: @resource.source,
      value: @resource[@page],
      action: params[:page] == 'screenshots' ? UserChange::ScreenshotsPosition : nil
    )
    render template: 'db_entries/edit_field'
  end

  def update
    version = Versioneers::FieldsVersioneer.new(@resource.object).premoderate(update_params, current_user, params[:reason])

    if version.persisted? && can?(:manage, version)
      version.accept current_user if params[:apply]
      version.take current_user if params[:take]
    end

    redirect_to @resource.edit_url, notice: i18n_t("changes_#{version.state}")
  end
end
