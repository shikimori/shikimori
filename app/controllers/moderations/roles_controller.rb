class Moderations::RolesController < ModerationsController
  before_action :set_role, except: %i[index]
  before_action :check_access, only: %i[update destroy]
  before_action :fetch_target_user, only: %i[update destroy]

  def index
    og noindex: true, nofollow: true
    og page_title: i18n_t('page_title')
  end

  def show
    # if @role =~ /\Anot_trusted_(?<role>[\w_]+)\Z/ &&
    #     !current_user.send("#{$LAST_MATCH_INFO[:role].gsub 'changer', 'moderator'}?")
    #   raise CanCan::AccessDenied
    # end

    og noindex: true, nofollow: true
    og page_title: @role.titleize

    breadcrumb i18n_t('page_title'), moderations_roles_url
    @back_url = moderations_roles_url

    @collection = role_users_scope
    @searched_collection = search_users_scope if params[:search]
  end

  def update
    @resource = ::Versions::RoleVersion.create!(
      user: current_user,
      item: @target_user,
      item_diff: {
        action: ::Versions::RoleVersion::Actions[:add],
        role: @role
      }
    )
    @resource.auto_accept
  end

  def destroy
    @resource = ::Versions::RoleVersion.create!(
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
  end

  def fetch_target_user
    @target_user = User.find params[:user_id]
  end

  def role_users_scope
    User
      .where("roles && '{#{Types::User::Roles[@role]}}'")
      .order(:nickname)
      .decorate
  rescue Dry::Types::ConstraintError
    redirect_to moderations_roles_url
  end

  def search_users_scope
    Users::Query.fetch
      .search(params[:search])
      .paginate([params[:page].to_i, 1].max, 45)
      .transform(&:decorate)
  end
end
