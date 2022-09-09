class Moderations::RolesController < ModerationsController
  before_action :set_role, except: %i[index]
  before_action :check_access, only: %i[update destroy]
  before_action :fetch_target_user, only: %i[update destroy]

  USERS_PER_PAGE = Moderations::UsersController::PER_PAGE
  VERSIONS_PER_PAGE = 25

  def index
    og noindex: true, nofollow: true
    og page_title: i18n_t('page_title')

    @back_url = moderations_url
  end

  def show
    redirect_to moderations_roles_url unless RolesPolicy.accessible? @role

    og noindex: true, nofollow: true
    og page_title: @role.titleize

    breadcrumb i18n_t('page_title'), moderations_roles_url
    @back_url = moderations_roles_url

    @collection = role_users_scope
    @searched_collection = search_users_scope
    @versions = versions_scope.paginate(page, VERSIONS_PER_PAGE).lazy_map(&:decorate)
  end

  def search
    @collection = search_users_scope
    render :show, formats: :json
  end

  def versions
    @versions = versions_scope
  end

  def update
    @resource = ::Versions::RoleVersion.create!(
      state: :pending,
      user: current_user,
      item: @target_user,
      item_diff: {
        action: ::Versions::RoleVersion::Actions[:add],
        role: @role
      }
    )
    @resource.auto_accept!
  end

  def destroy
    @resource = ::Versions::RoleVersion.create!(
      state: :pending,
      user: current_user,
      item: @target_user,
      item_diff: {
        action: ::Versions::RoleVersion::Actions[:remove],
        role: @role
      }
    )
    @resource.auto_accept!
  end

private

  def check_access
    authorize! :"manage_#{@role}_role", User
  end

  def set_role
    @role = params[:id]
    @is_versions = @role == 'version_moderator'
  end

  def fetch_target_user
    @target_user = User.find params[:user_id]
  end

  def role_users_scope
    QueryObjectBase
      .new(User.where("roles && '{#{Types::User::Roles[@role]}}'").order(:nickname))
      .paginate(page, USERS_PER_PAGE)
      .lazy_map(&:decorate)
  rescue Dry::Types::ConstraintError
    redirect_to moderations_roles_url
  end

  def search_users_scope
    scope = Users::Query.fetch
    scope = params[:phrase].present? ? scope.search(params[:phrase]) : scope.none
    scope
      .paginate(params[:action] == 'search' ? page : 1, USERS_PER_PAGE)
      .lazy_map(&:decorate)
  end

  def versions_scope
    Moderation::ProcessedVersionsQuery
      .fetch(Moderation::VersionsItemTypeQuery::Types[:role], nil)
      .where("item_diff->>'role' = ?", @role)
      .paginate(params[:action] == 'versions' ? page : 1, VERSIONS_PER_PAGE)
      .lazy_map(&:decorate)
  end

  def page
    [params[:page].to_i, 1].max
  end
end
