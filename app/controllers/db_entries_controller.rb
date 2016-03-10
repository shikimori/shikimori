class DbEntriesController < ShikimoriController
  before_action :authenticate_user!, only: [:edit, :edit_field, :update]

  def tooltip
    noindex
  end

  def versions
    render template: 'db_entries/versions', formats: :json
  end

  def edit
    noindex
    page_title i18n_t 'entry_edit'
  end

  def edit_field
    noindex
    page_title i18n_t 'entry_edit'
    @field = params[:field]

    authorize! :significant_change, Version if significant_fields.include?(@field)

    render template: 'db_entries/edit_field'
  end

  def update
    authorize! :significant_change, Version if (update_params.keys & significant_fields).any?

    version = if update_params[:image]
      update_image
    else
      update_version
    end

    if version.persisted?
      redirect_to @resource.edit_url, notice: i18n_t("version_#{version.state}")
    else
      redirect_to :back, alert: i18n_t('no_changes')
    end
  end

private

  def significant_fields
    @resource.object.class::SIGNIFICANT_FIELDS
  end

  def update_version
    version = Versioneers::FieldsVersioneer.new(@resource.object)
      .premoderate(update_params, current_user, params[:reason])

    version.accept current_user if version.persisted? && can?(:manage, version)
    version
  end

  def update_image
    Versioneers::PostersVersioneer.new(@resource.object)
      .postmoderate(update_params[:image], current_user, params[:reason])
  end
end
