# TODO: отрефакторить толстый контроллер
class GroupsController < ApplicationController
  before_filter :check_auth, only: [:new, :settings, :apply]
  helper_method :breadcrumbs

  VisibleEntries = 12

  # список всех групп
  def index
    @groups = Group
      .joins(:member_roles, :thread)
      .group('groups.id')
      .having('count(group_roles.id) > 0')
      .order('entries.updated_at desc')
      .to_a

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

    #set_meta_tags noindex: true, nofollow: true
    @group ||= Group
      .includes(:animes)
      .includes(:mangas)
      .includes(:characters)
      .find(params[:id])

    @members ||= @group
      .member_roles
      .includes(:user)
      .order(created_at: :desc)
      .take(9)
        .map(&:user)

    @animes = @group
      .animes
      .uniq(&:id)
      .shuffle
      .take(VisibleEntries)
      .sort_by { |v| v.ranked }

    @mangas = @group
      .mangas
      .uniq(&:id)
      .shuffle
      .take(VisibleEntries)
      .sort_by { |v| v.ranked }

    @characters = @group
      .characters
      .uniq(&:id)
      .shuffle
      .take(VisibleEntries)
      .sort_by { |v| v.name }

    @images ||= @group.images
        .order(created_at: :desc)
        .take(12)

    @page_title ||= @group.name

    @comments = @group.thread.comments.with_viewed(current_user).limit(15)

    @sub_layout = 'group'
    @pages = ['info', 'members']
    @pages << 'images'# unless @images.empty?
    @pages << 'settings' if user_signed_in? && @group.can_be_edited_by?(current_user)
    @pages << 'animes' if @animes.size == VisibleEntries
    @pages << 'mangas' if @mangas.size == VisibleEntries
    @pages << 'characters' if @characters.size == VisibleEntries

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

    @group ||= Group.find(params[:id])
    @members ||= @group
      .member_roles
      .includes(:user)
      .order(created_at: :desc)
      .map(&:user)
    @page_title = [@group.name, 'Участники']
    show
  end

  # аниме группы
  def animes
    set_meta_tags noindex: true

    @group ||= Group.find(params[:id])
    @entries = @group.animes.uniq(&:id)
    @page_title = [@group.name, 'Аниме']

    show
  end

  # манга группы
  def mangas
    set_meta_tags noindex: true

    @group ||= Group.find(params[:id])
    @entries = @group.mangas.uniq(&:id)
    @page_title = [@group.name, 'Манга']

    show
  end

  # аниме группы
  def characters
    set_meta_tags noindex: true

    @group ||= Group.find(params[:id])
    @entries = @group.characters.uniq(&:id)
    @page_title = [@group.name, 'Персонажи']

    show
  end

  # картинки группы
  def images
    set_meta_tags noindex: true, nofollow: true

    @group ||= Group.find(params[:id])
    @images ||= @group.images
        .order(created_at: :desc)
    @page_title = [@group.name, 'Картинки']
    show
  end

  # настройки группы
  def settings
    @group ||= Group.find(params[:id])
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
      @group = Group.create!({
        owner_id: current_user.id,
        join_policy: GroupJoinPolicy::Free
      })
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
        @group.moderator_roles.each do |v|
          v.update_attribute(:role, GroupRole::Member)
        end
        # а затем ставим тем, кто переданы запросом
        params[:moderators].select {|v| v != '' }.each do |v|
          user = User.find_by_nickname(v)
          GroupRole.find_by_user_id_and_group_id(user.id, @group.id)
              .update_attribute(:role, GroupRole::Moderator)
        end
      end

      if params[:admins]
        # сбрасываем всем права админа
        @group.admin_roles.each do |v|
          v.update_attribute(:role, GroupRole::Member)
        end
        # а затем ставим тем, кто переданы запросом
        params[:admins].select {|v| v != '' }.each do |v|
          user = User.find_by_nickname(v)
          GroupRole.find_by_user_id_and_group_id(user.id, @group.id)
              .update_attribute(:role, GroupRole::Admin)
        end
      end

      if params[:kicks]
        # а затем ставим тем, кто переданы запросом
        params[:kicks].select {|v| v != '' }.each do |v|
          user = User.find_by_nickname(v)
          GroupRole.find_by_user_id_and_group_id(user.id, @group.id).destroy
        end
      end
    end

    params[:group].each do |k,v|
      if k == 'logo'
        @group.logo = v
      else
        @group[k] = v
      end
    end
    @group.display_images = params[:group].include? :display_images
    @group.save!

    if params[:id] == 'new'
      redirect_to url_for(@group)
    else
      redirect_to_back_or_to url_for(@group), notice: 'Изменения сохранены'
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
end
