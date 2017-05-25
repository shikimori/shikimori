class DbEntriesController < ShikimoriController
  before_action :authenticate_user!, only: [:edit, :edit_field, :update]

  # it always should be executed before :fetch_resource
  before_action :resource_klass_page_title, if: :resource_id
  before_action :fetch_resource, if: :resource_id

  def tooltip
    noindex
  end

  def versions
  end

  def edit
    noindex
    page_title i18n_t 'entry_edit'
  end

  def edit_field
    noindex
    page_title i18n_t 'entry_edit'
    @field = params[:field]

    if significant_fields.include? @field
      authorize! :significant_change, Version
    end

    render template: 'db_entries/edit_field'
  end

  def update
    if (update_params.keys & significant_fields).any?
      authorize! :significant_change, Version
    end

    version = if update_params[:image]
      update_image
    elsif update_params[:external_links]
      update_external_links
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

  def resource_klass_page_title
    page_title resource_klass.model_name.human
  end

  def significant_fields
    @resource.object.class::SIGNIFICANT_FIELDS.select do |field|
      field != 'image' || @resource.image.exists?
    end
  end

  def update_version
    version = Versioneers::FieldsVersioneer
      .new(@resource.object)
      .premoderate(
        update_params.to_unsafe_h,
        current_user,
        params[:reason]
      )

    version.accept current_user if version.persisted? && can?(:accept, version)
    version
  end

  def update_image
    versioneer = Versioneers::PostersVersioneer.new(@resource.object)

    if can? :significant_change, @resource.object
      versioneer.postmoderate(
        update_params[:image],
        current_user,
        params[:reason]
      )
    else
      versioneer.premoderate(
        update_params[:image],
        current_user,
        params[:reason]
      )
    end
  end

  def update_external_links
    version = Versioneers::CollectionVersioneer
      .new(@resource.object, :external_links)
      .premoderate(
        update_params[:external_links],
        current_user,
        params[:reason]
      )

    version.accept current_user if version.persisted? && can?(:accept, version)
    version
  end
end
