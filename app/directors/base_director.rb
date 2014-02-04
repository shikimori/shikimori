class BaseDirector
  def initialize(controller)
    @controller = controller
    @controller.instance_variable_set :@director, self

    @breadcrumbs = {}
    @redirected = false
  end

  # осуществляем редирект, если надо
  def redirect! url=nil
    if redirect?
      @controller.redirect_to url || entry.url, :status => :moved_permanently
      @redirected = true
    end
  end

  # редиректнута ли страница?
  def redirected?
    @redirected
  end

  # вкладки старницы
  def pages
    @pages ||= begin
      self.class.pages.each_with_object([]) do |(page, condition), memo|
        processed_page = if page.kind_of? Symbol
          page.to_s
        elsif page.kind_of? Proc
          self.instance_exec(&page)
        else
          page
        end
        if condition.nil? || instance_exec(&condition)
          memo << processed_page
        end
      end
    end
  end

  # для корректного поведения всякого
  def respond_to? method, include_private = false
    if @controller.respond_to?(method, include_private)
      true
    else
      super method, include_private
    end
  end

  # текущая страница
  def partial
    page_entry = pages[page_index]

    if page_entry.kind_of? Array
      view_root + '/' +
          page_entry[0] + '/' +
          page_entry[1][page_entry[1].index params[:subpage]]
    else
      view_root + '/' + page_entry
    end
  end

  # индекс текущей страницы
  def page_index
    pages.index do |page|
      if page.kind_of? Array
        page[0].eql?(params[:page]) && page[1].include?(params[:subpage])

      else
        page.eql? params[:page]
      end
    end || raise(NotFound.new("page: #{params[:page]}"))
  end

  # хлебные крошки
  def breadcrumbs
    @built_crumbs ||= begin
      build_crumbs
      @breadcrumbs
    end
  end

private
  def entry
    @controller.instance_variable_get :@entry
  end

  def method_missing method, *args, &block
    # имя экшена в контроллер не прокидываем - иначе зациклится!!!
    if method.to_s != @controller.view_context.params[:action]
      @controller.send(method, *args, &block)
    else
      super method, *args, &block
    end
  end

  def append_crumb! title, url
    @breadcrumbs[title] = url
  end

  def append_title! title
    page_title = @controller.instance_variable_get :@page_title
    if page_title
      if page_title.kind_of?(Array)
        page_title << title
      else
        page_title = [page_title, title]
      end
    else
      page_title = title
    end

    @controller.instance_variable_set :@page_title, [page_title].flatten.compact.uniq
  end

  def view_root
    params[:controller]
  end

  class << self
    attr_reader :pages

    def page entry, condition=nil
      if entry.kind_of? Array
        entry = entry.map do |v|
          if v.kind_of? Array
            v.map(&:to_s)
          else
            v.to_s
          end
        end
      end
      (@pages ||= []) << [entry, condition]
    end
  end
end
