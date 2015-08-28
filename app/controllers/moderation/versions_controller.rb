class Moderation::VersionsController < ShikimoriController
  load_and_authorize_resource except: [:index]

  before_action { page_title i18n_t('content_changes') }

  def show
    noindex
    page_title i18n_t('content_change', version_id: @resource.id)
  end

  def tooltip
    noindex
  end

  def index
    @versions = VersionsView.new
  end

  def accept
    transition :accept, 'changes_accepted'
  end

  def take
    transition :take, 'changes_accepted'
  end

  def reject
    transition :reject, 'changes_rejected'
  end

  def accept_taken
    transition :accept_taken, 'changes_accepted'
  end

  def take_accepted
    transition :take_accepted, 'changes_accepted'
  end

  def destroy
    transition :to_deleted, 'changes_deleted'
  end

  def create
    if @resource.save
      @resource.accept current_user if can? :manage, @resource
      redirect_to :back, notice: i18n_t("version_#{@resource.state}")

    else
      redirect_to :back, alert: @resource.errors.full_messages
    end
  end

private

  def transition action, success_message
    @resource.send action, current_user, params[:reason]
    redirect_to_back_or_to moderation_versions_url, notice: i18n_t(success_message)

  rescue StateMachine::InvalidTransition
    redirect_to_back_or_to moderation_versions_url, alert: i18n_t('changes_failed')
  end

  def create_params
    params
      .require(:version)
      .permit(
        :item_id,
        :item_type,
        :user_id,
        :reason,
        item_diff: (
          [:russian] +
          Anime::DESYNCABLE +
          Manga::DESYNCABLE +
          Character::DESYNCABLE +
          Person::DESYNCABLE +
          DbEntry::SIGNIFICANT_FIELDS
        ).uniq.each_with_object({}) { |v,memo| memo[v] = [] }
      )
  end
end
