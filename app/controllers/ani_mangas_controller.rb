class AniMangasController < ApplicationController
  include ActionView::Helpers::TextHelper
  include EntriesHelper
  include ActionView::Helpers::DateHelper
  include ApplicationHelper
  include AniMangaHelper

  AutocompleteLimit = 14

  layout false, only: [:tooltip, :related_all]
  respond_to :html, only: [:show, :tooltip, :related_all]
  respond_to :json, only: :autocomplete
  respond_to :html, :json, only: :page

  before_filter :authenticate_user!, only: [:edit]

  caches_action :page, :characters, :show, :related_all, :cosplay, :tooltip,
                cache_path: proc {
                  id = params[:anime_id] || params[:manga_id] || params[:id]
                  @entry ||= klass.find(id.to_i)
                  "#{klass.name}|#{Digest::MD5.hexdigest params.to_json}|#{@entry.updated_at.to_i}|#{@entry.thread.updated_at.to_i}|#{json?}"
                },
                unless: proc { user_signed_in? },
                expires_in: 2.days

  # отображение аниме или манги
  def show
    @entry = present klass.find(entry_id.to_i)
    direct
  end

  # все связанные элементы с аниме/мангой
  def related_all
    show
  end

  # все связанные элементы с аниме/мангой
  def other_names
    @entry ||= klass.find(params[:id].to_i)
    render partial: 'ani_mangas/other_names', formats: :html
  end

  # подстраница аниме или манги
  def page
    show
    render :show unless @director.redirected?
  end

  # редактирование аниме
  def edit
    show
    render :show unless @director.redirected?
  end

  # подстраница косплея
  def cosplay
    show
    render :show unless @director.redirected?
  end

  # торренты к эпизодам аниме
  def episode_torrents
    @entry = present klass.find(params[:id].to_i)
    render json: @entry.files.episodes_data
  end

  # тултип
  def tooltip
    @entry = klass.find params[:id].to_i
    direct
  end

  # автодополнение
  def autocomplete
    @items = AniMangaQuery.new(klass, params, current_user).complete
  end

private
  # класс текущего элемента
  def klass
    @klass ||= Object.const_get(self.class.name.underscore.split('_')[0].singularize.camelize)
  end

  def entry_id
    params[:anime_id] || params[:manga_id] || params[:id]
  end
  ## часть заголовка с названием текущего элемента
  #def entry_title
    #"#{@entry.russian_kind} #{HTMLEntities.new.decode(@entry.name)}"
  #end
end
