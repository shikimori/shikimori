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
    page_title i18n_t('entry_edit')
    @field = params[:field]

    authorize! :significant_change, Version if significant_fields.include?(@field)

    render template: 'db_entries/edit_field'
  end

  def update
    authorize! :significant_change, Version if (update_params.keys & significant_fields).any?

    version = Versioneers::FieldsVersioneer.new(@resource.object)
      .premoderate(update_params, current_user, params[:reason])

    version.accept current_user if version.persisted? && can?(:manage, version)
    redirect_to @resource.edit_url, notice: i18n_t("version_#{version.state}")
  end

private

  def significant_fields
    @resource.object.class::SIGNIFICANT_FIELDS
  end
end
