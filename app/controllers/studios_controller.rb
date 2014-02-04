class StudiosController < ApplicationController
  # список студий
  def index
    @page_title = 'Аниме студии'
    @description = 'Список наиболее крупных студий, занимающихся созданием аниме; отсортировано по объёму работ.'
    set_meta_tags description: @description

    @studios = Studio.joins(:animes)
                     .where("animes.kind != 'Special'")
                     .group('studios.id')
                     .select('studios.*, count(animes.id) as animes_count, max(animes.aired_on) as max_year, min(animes.aired_on) as min_year')
                     .order('animes_count desc')

  end

  # отображение одной студии
  def show
    set_meta_tags :noindex => true, :nofollow => true
    @studio = Studio.find(params[:id].to_i)
    redirect_to animes_path(:studio => @studio) and return
    # у студий больше нет персональных страниц
    if @studio.to_param != params[:id]
      redirect_to @studio, :status => :moved_permanently and return
    end
    raise Forbidden unless @studio.real? || (!@studio.real? && user_signed_in? && current_user.admin?)

    @page_title = @studio.name

    @genres = Rails.cache.fetch('genres', :expires_in => 30.minutes) do
      Genre.all
    end

    @current_page = (params[:page] || 1).to_i
    @per_page = AnimesController::ENTRIES_PER_PAGE
    @animes = AniMangaCollection.datasource(params.merge(:klass => Anime), current_user || nil)
                                .where(:id => @studio.all_animes.select(:id).map(&:id))
    if (params[:search])
      @animes = @animes.where("name like ? or name like ? or synonyms like ? or english like ? or japanese like ? or russian like ? or name like ?",
                              params[:search].downcase.gsub(/([A-zА-я0-9])/, '\1% ').sub(/ $/, ''),
                              "%#{params[:search].downcase.gsub(' ', '% ')}%",
                              "%#{params[:search].downcase.gsub(' ', '% ')}%",
                              "%#{params[:search].downcase.gsub(' ', '% ')}%",
                              "%#{params[:search].downcase.gsub(' ', '% ')}%",
                              "%#{params[:search].downcase.gsub(' ', '% ')}%",
                              "%#{params[:search].downcase.broken_translit.gsub(' ', '% ')}%")
    end
    @animes = @animes.paginate(:page => @current_page, :per_page => @per_page)

    @studio_changes = UserChange.where(:model => :studio, :column => :description, :item_id => @studio.id).
                                 where(:status => UserChangeStatus::Accepted).
                                 select('distinct(user_id)').
                                 includes(:user).
                                 order(created_at: :desc).
                                 all

    paginate @animes, :action => :show,
                      :genre => params[:genre],
                      :studio => params[:studio],
                      :order => params[:order],
                      :type => params[:type],
                      :search => params[:search],
                      :options => params[:options],
                      :season => params[:season],
                      :mylist => params[:mylist]
    @first_page = @first_page.sub(/(.*\/studios\/[^\/]+)\/order-by\/ranked/, '\1')
    @prev_page = @prev_page.sub(/(.*\/studios\/[^\/]+)\/order-by\/ranked/, '\1')
    respond_to do |format|
      format.html
      format.json { render :json => {:content => render_to_string(:partial => 'ani_mangas/entry.html.erb', :layout => false,  :collection => @animes),
                                     :current_page => @current_page,
                                     :total_pages => @total_pages,
                                     :first_page => @first_page,
                                     :last_page => @last_page,
                                     :next_page => @next_page,
                                     :prev_page => @prev_page,
                                     :title_page => @page_title,
                                     :title_notice => @title_notice
                                    } }
    end
  end

  # изменение описания студии
  def apply
    raise Forbidden unless current_user.admin?
    studio = Studio.find(params[:id])
    studio.update_attribute(:description, params[:studio][:description])
    redirect_to studio, :status => :moved_permanently
  end
end
