# TODO: отрефакторить толстый контроллер
class GroupsController < ApplicationController
  before_action :check_auth, only: [:new, :settings, :apply]
  before_action :fetch_group, only: [:show, :members, :animes, :mangas, :characters, :images]
  helper_method :breadcrumbs

  # список всех групп
  def index
    @page = [params[:page].to_i, 1].max
    @limit = [[params[:limit].to_i, 10].max, 30].min

    @groups, @add_postloader = ClubsQuery.new.postload @page, @limit

    @page_title = 'Клубы'
  end

  # создание новой группы
  def new
    @group = Group.new
    @page_title = 'Новый клуб'
  end

  # страница группы
  def show
    params[:type] ||= 'info'

    @group ||= Group.find(params[:id]).decorate

    @page_title ||= @group.name

    @sub_layout = 'group'
    @pages = ['info', 'members']
    @pages << 'images'# unless @images.empty?
    @pages << 'settings' if user_signed_in? && @group.can_be_edited_by?(current_user)
    @pages << 'animes' if @group.animes.size == GroupDecorator::VisibleEntries
    @pages << 'mangas' if @group.mangas.size == GroupDecorator::VisibleEntries
    @pages << 'characters' if @group.characters.size == GroupDecorator::VisibleEntries

    if @group.belongs_to_translators?
      @pages << 'translation_planned'
      @pages << 'translation_finished'
    end

    respond_to do |format|
      format.html { render 'groups/show', formats: :html }
      format.json {
        render json: {
          content: render_to_string(partial: "#{params[:controller]}/#{params[:type]}", layout: false, formats: :html),
          title_page: @page_title
        }
      }
    end
  end

  # участники группы
  def members
    set_meta_tags noindex: true, nofollow: true

    @page_title = [@group.name, 'Участники']
    show
  end

  # аниме группы
  def animes
    set_meta_tags noindex: true

    @page_title = [@group.name, 'Аниме']

    show
  end

  # манга группы
  def mangas
    set_meta_tags noindex: true

    @page_title = [@group.name, 'Манга']

    show
  end

  # аниме группы
  def characters
    set_meta_tags noindex: true

    @page_title = [@group.name, 'Персонажи']

    show
  end

  # картинки группы
  def images
    set_meta_tags noindex: true, nofollow: true

    @page_title = [@group.name, 'Картинки']

    show
  end

  # настройки группы
  def settings
    @group ||= Group.find(params[:id]).decorate
    raise Forbidden unless @group.can_be_edited_by?(current_user)
    @page_title = [@group.name, 'Настройки']
    show
  end

  def update
    apply
  end

  def create
    params[:id] = 'new'
    apply
  end

  # изменение группы
  def apply
    if params[:id] == 'new'
      @group = Group.create!(
        owner_id: current_user.id,
        join_policy: :free_join,
        comment_policy: :free_comment
      )
      @group.admin_roles.create! user_id: current_user.id, role: GroupRole::Admin
    else
      @group = Group.find(params[:id])
    end

    raise Forbidden unless @group.can_be_edited_by?(current_user)

    if params[:animes]
      @group.animes = []
      params[:animes].map(&:to_i).select {|v| v != 0 }.each do |v|
        @group.animes << Anime.find(v)
      end
    end

    if params[:mangas]
      @group.mangas = []
      params[:mangas].map(&:to_i).select {|v| v != 0 }.each do |v|
        @group.mangas << Manga.find(v)
      end
    end

    if params[:characters]
      @group.characters = []
      params[:characters].map(&:to_i).select {|v| v != 0 }.each do |v|
        @group.characters << Character.find(v)
      end
    end

    if @group.admins.include?(current_user)
      if params[:moderators]
        # сбрасываем всем права модератора
        @group.moderator_roles.update_all role: GroupRole::Member
        # а затем ставим тем, кто переданы запросом
        params[:moderators].select(&:present?).each do |v|
          user = User.find_by_nickname(v)
          GroupRole.find_by_user_id_and_group_id(user.id, @group.id)
              .update(role: GroupRole::Moderator)
        end
      end

      if params[:admins]
        # сбрасываем всем права админа
        @group.admin_roles.update_all role: GroupRole::Member
        # а затем ставим тем, кто переданы запросом
        params[:admins].select(&:present?).each do |v|
          user = User.find_by_nickname(v)
          GroupRole.find_by_user_id_and_group_id(user.id, @group.id)
              .update(role: GroupRole::Admin)
        end
      end

      if params[:bans]
        # удаляем все баны
        @group.bans.delete_all
        # и вешаем их заново
        params[:bans].select(&:present?).each do |nickname|
          @group.ban User.find_by(nickname: nickname)
        end
      end

      if params[:kicks]
        # а затем ставим тем, кто переданы запросом
        params[:kicks].select(&:present?).each do |v|
          @group.leave User.find_by(nickname: v)
        end
      end
    end

    @group.update group_params

    if params[:id] == 'new'
      redirect_to club_url @group
    else
      redirect_to_back_or_to club_url(@group), notice: 'Изменения сохранены'
    end
  end

  # получение элементов для автодополнения
  def autocomplete
    group = Group.find(params[:id])

    items = group
      .members
      .where("nickname = ? or nickname like ?", params[:search], "#{params[:search]}%")
      .order(:nickname)
      .to_a

    render json: items.reverse.map { |item|
      {"data" => item.nickname,
       "value" => item.nickname,
       "label" => render_to_string(partial: 'users/suggest', layout: false, locals: { user: item }, formats: :html)
      }
    }
  end

  def breadcrumbs
    {
      'Клубы' => groups_url
    }
  end

private
  def group_params
    params.require(:group).permit(:name, :description, :join_policy, :comment_policy, :display_images, :logo)
  end

  def fetch_group
    @group = Group.find(params[:id]).decorate
  end
end
