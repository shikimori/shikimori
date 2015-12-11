class ForumController < ShikimoriController
  @@first_page_comments = 3
  @@other_page_comments = 1

  before_action :build_background, only: [:index, :show, :new, :edit, :create, :create, :update]
  helper_method :sticked_topics

  #caches_action :site_block,
                #:cache_path => proc { "#{request.path}|#{params.to_json}|#{Topic.last.updated_at}|#{json?}" },
                #:unless => proc { user_signed_in? },
                #:expires_in => 2.days

  def index
    @h1 = @linked && @linked.respond_to?(:name) ? @linked.name : @section[:title]
    @page_title = @page == 1 ? @section[:meta_title] : [@section[:meta_title], "Страница #{@page}"]

    set_meta_tags(
      keywords: @section[:meta_keywords],
      description: @section[:meta_description]
    ) unless json?

    @json.merge!(
      h1: @h1 || @section[:name],
      title_notice: @section[:description],
      title_page: @page_title
    ) if json?
  end

  def show
    #@h1 = @topic.linked && @topic.class != AnimeNews ? @topic.linked.name : @topic.title
    @h1 = @topic.title
    @page_title = @topic.linked && @topic.linked.respond_to?(:name) ?
      [@section[:meta_title], @topic.linked.name, @topic.to_s] :
      [@section[:meta_title], @h1]

    kinds = case @topic.linked.class.name
      when Anime.name then ['аниме ', 'аниме ']
      when Manga.name then ['манга ', 'манги ']
      when Character.name then ['персонаж ', 'персонажа ']
      else nil
    end if @topic.linked

    set_meta_tags({
        keywords: "%s%s%s, обсуждение, форум, дискуссия" % [
          defined?(kinds) && kinds ? kinds[0] : '',
          @h1,
          @topic.linked && @topic.linked.respond_to?(:russian) && !@topic.linked.russian.blank? ? ', '+@topic.linked.russian : ''
        ],
        description: defined?(kinds) && kinds ?
          "Обсуждение %s%s%s" % [
              kinds[1],
              @h1,
              @topic.linked && @topic.linked.respond_to?(:russian) && !@topic.linked.russian.blank? ? ' ('+@topic.linked.russian+')' : ''
            ] :
          @h1,
      })

    @json.merge!({
        h1: @h1,
        title_notice: @section[:description],
        title_page: @page_title
      }) if json?
  end

  def new
    @h1 = "Новый топик"
    @page_title = [@section[:meta_title], @h1]
    @notice = "в раздел #{@section[:name]}."

    @json.merge!({
        h1: @h1,
        title_notice: @notice,
        title_page: @page_title
      }) if json?
  end

  def edit
    @h1 = "Изменение топика"
    @page_title = [@section[:meta_title], @h1]
    @notice = "в разделе #{@section[:name]}."

    @json.merge!(
      h1: @h1,
      title_notice: @notice,
      title_page: @page_title
    ) if json?
  end

private
  # построние окружения форума
  # TODO: отрефакторить
  def build_background
    redirect_to :root, status: 301 and return false if params[:format] == 'user'

    params[:section] ||= Section::static[:all][:permalink]

    @sections = Section.visible
    @section = Section.find_by_permalink params[:section]

    @faye_subscriptions = case @section.permalink
      when Section::static[:all].permalink
        Section.real.map {|v| "section-#{v.id}" } +
          (user_signed_in? ? current_user.groups.map { |v| "group-#{v.id}" } : [])

      #when Section::static[:feed].permalink
        #["user-#{current_user.id}", FayePublisher::BroadcastFeed]

      else
        ["section-#{@section.id}"]
    end.to_json if user_signed_in?

    if params[:linked]# || (params[:topic] && !params[:topic].kind_of?(Hash))
      ##@topic = Entry.with_viewed(current_user).find(params[:topic]) if params[:topic]

      #@linked = if @topic && @section.permalink != 'v'
        #@topic.linked
      #else
      @linked = case @section.permalink
        when 'a'
          id = CopyrightedIds.instance.restore params[:linked], 'anime'
          Anime.find id

        when 'm'
          id = CopyrightedIds.instance.restore params[:linked], 'manga'
          Manga.find id

        when 'c'
          id = CopyrightedIds.instance.restore params[:linked], 'character'
          Character.find id

        when 'g'
          Group.find(params[:linked].to_i)

        #when 'reviews' then Review.find(params[:linked].to_i)
        else nil
      end
      #end
      #@linked_presenter = if @linked.class == Review
        #@linked.entry.decorate
      #elsif @linked
        #@linked.decorate
      #end
    end

    raise NotFound, "неизвестный раздел: #{params[:section]}" unless @section

    @news = WellcomeNewsPresenter.new# if user_signed_in?

    @json = if json?
      {
        action: params[:action],
        new_topic_url: new_topic_url(section: @section.permalink, linked: @linked),
        section: @section.permalink,
      } if json?
    else
      {}
    end
  end

  # прикреплённые топики на форуме
  def sticked_topics
    rules = [
      { url: '/s/79042-Pravila-sayta', title: "#{t 'site_rules'}", description: 'Что не стоит делать на сайте' },
      { url: '/s/85018-FAQ-Chasto-zadavaemye-voprosy', title: 'FAQ', description: "#{t 'faq'}" },
      { url: '/s/103553-Opisaniya-zhanrov', title: 'Описания жанров', description: 'Для желающих помочь сайту' },
      { url: '/s/10586-Pozhelaniya-po-saytu', title: 'Идеи и предложения', description: 'Было бы неплохо реализовать это...' },
      { url: '/s/102-Tema-ob-oshibkah', title: 'Ошибки', description: 'Топик о любых проблемах на сайте' }
    ]

    {
      'f' => rules,
      'all' => rules,
      'news' => rules,
      'a' => rules,
      'm' => rules,
      'c' => rules,
      's' => rules,
      'v' => rules,
      'o' => rules,
    }[@section.permalink] || []
  end
end
