require 'sidekiq/web'

Site::Application.routes.draw do
  ani_manga_format = '(/type/:type)(/status/:status)(/season/:season)(/genre/:genre)(/studio/:studio)(/publisher/:publisher)(/duration/:duration)(/rating/:rating)(/options/:options)(/mylist/:mylist)(/search/:search)(/order-by/:order)(/page/:page)(.:format)'

  concern :db_entry do |options|
    member do
      get :comments
      get :favoured
      get 'tooltip(/:minified)' => :tooltip, as: :tooltip, minified: /minified/
      get 'edit/:field' => :edit_field, as: :edit_field, field: options[:fields]
      get 'versions/page/:page' => :versions, as: :versions
    end
  end
  concern :autocompletable do
    get :autocomplete, on: :collection, format: :json
  end
  concern :searcheable do
    get 'search/:search(/page/:page)' => :index, as: :search, on: :collection, constraints: { page: /\d+/ }
  end

  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks',
    registrations: 'users/registrations',
    passwords: 'users/passwords'
  }

  resources :animes, only: [], concerns: [:autocompletable]
  resources :mangas, only: [], concerns: [:autocompletable]
  resources :characters, only: [], concerns: [:autocompletable]
  resources :people, only: [], concerns: [:autocompletable]
  resources :seyu, only: [], concerns: [:autocompletable]
  resources :users, only: [], concerns: [:autocompletable]

  # site pages
  resources :pages, path: '/', only: [] do
    collection do
      get :privacy
      get :page404
      get :page503
      get :raise_exception
      get :timeout_120s

      get :bb_codes
      get :feedback
      get 'apanel' => :admin_panel
    end
  end

  resources :user_images, only: [:create] # TODO: remove after 01.01.2016
  resources :messages, only: [:create] do
    post :preview, on: :collection
  end

  # комментарии
  resources :comments do
    resources :bans, only: [:new], controller: 'moderations/bans'
    resources :abuse_requests, controller: 'moderations/abuse_requests', only: [] do
      resources :bans, only: [:new], controller: 'moderations/bans'

      collection do
        post :abuse
        post :spoiler
        post :offtopic
        post :review
      end
    end

    collection do
      get :smileys
      post :preview
      get 'fetch/:comment_id/:topic_type/:topic_id(/:review)/:skip/:limit' => :fetch, as: :fetch, topic_type: /Entry|User/
      get ':commentable_type/:commentable_id(/:review)/:offset/:limit', action: :postloader, as: :model
    end
  end
  get 'comments/chosen/:ids(/:order)' => 'comments#chosen', as: :comments_chosen

  namespace :moderations do
    resources :versions, only: [:show, :create, :destroy] do
      member do
        get :tooltip
        post :accept
        post :take
        post :reject
        post :accept_taken
        post :take_accepted
      end
    end
    scope ':type/', type: /content|anime_video/ do
      resources :versions, only: [:index] do
        get '(/page/:page)' => :index, as: :index, on: :collection
      end
    end

    resources :bans, only: [:create, :index] do
      get '/page/:page', action: :index, as: :page, on: :collection
    end
    resources :abuse_requests, only: [:index, :show] do
      get '/page/:page', action: :index, as: :page, on: :collection

      member do
        post :take
        post :deny
      end
    end
    resources :reviews, only: [:index] do
      get '/page/:page', action: :index, as: :page, on: :collection

      member do
        post :accept
        post :reject
      end
    end

    resources :anime_video_reports, only: [:index, :create] do
      get '/page/:page', action: :index, as: :page, on: :collection

      member do
        get :accept
        get :accept_edit
        get :reject
        get :work
        get :cancel
      end
    end
  end

  apipie
  namespace :api, defaults: { format: 'json' } do
    scope module: :v1 do
      resources :animes, only: [:show, :index] do
        member do
          get :roles
          get :similar
          get :related
          get :screenshots
          get :franchise
        end
        get :search, on: :collection
      end
      resource :calendar, only: [:show]
      resources :mangas, only: [:show, :index] do
        member do
          get :roles
          get :similar
          get :related
          get :franchise
        end
        get :search, on: :collection
      end

      resources :devices, only: [:create, :update, :index, :destroy] do
        get :test, on: :member
      end
      resources :characters, only: [:show] do
        get :search, on: :collection
      end
      resources :people, only: [:show] do
        get :search, on: :collection
      end

      resources :studios, only: [:index]
      resources :genres, only: [:index]
      resources :publishers, only: [:index]

      resources :sections, only: [:index]
      resources :topics, only: [:index, :show]
      resources :comments, only: [:show, :index, :create, :update, :destroy]

      resources :user_images, only: [:create]

      resources :clubs, only: [:show, :index] do
        member do
          get :members
          get :animes
          get :mangas
          get :characters
          get :images

          post :join
          post :leave
        end
      end

      resources :messages, only: [:show, :create, :update, :destroy] do
        collection do
          post :mark_read
          post :delete_all
          post :read_all
        end
      end

      resources :user_rates, only: [:create, :update, :destroy] do
        post :increment, on: :member

        collection do
          scope ':type', type: /anime|manga/ do
            delete :cleanup
            delete :reset
          end
        end
      end
      resources :nickname_changes, only: [] do
        delete :cleanup, on: :collection
      end

      resource :access_token, only: [:show, :create]
      resource :authenticity_token, only: [:show]

      resources :bans, only: [:index]

      devise_scope :user do
        resources :sessions, only: [:create]
      end

      resources :users, only: [:index, :show] do
        collection do
          get :whoami
        end
        member do
          get :info
          get :friends
          get :clubs
          get :favourites
          get :messages
          get :unread_messages
          get :history
          get :anime_rates
          get :manga_rates
          get :bans
        end
      end

      resources :appears, only: [:create], controller: 'appear'
      resources :friends, only: [] do
        post '/', action: :create, on: :member
        delete '/', action: :destroy, on: :member
      end
      resources :ignores, only: [] do
        post '/', action: :create, on: :member
        delete '/', action: :destroy, on: :member
      end

      resources :dialogs, only: [:index, :show, :destroy]
      resources :stats, only: [] do
        get :active_users, on: :collection
      end

      resources :constants do
        collection do
          get :anime
          get :manga
          get :user_rate
          get :club
          get :smileys
        end
      end
    end
  end

  constraints MangaOnlineDomain do
    get '/', to: 'manga_online/mangas#index'
    get 'mangas/:id' => 'manga_online/mangas#show', as: :online_manga_show
    get 'chapters/:id(/:page)' => 'manga_online/chapters#show', as: :online_manga_chapter_show

    get 'robots.txt' => 'robots#manga_online'
  end

  constraints AnimeOnlineDomain do
    get '/', to: 'anime_online/dashboard#show'
    get '/page/:page', to: 'anime_online/dashboard#show', as: :anime_dashboard_page

    get 'pingmedia_test_1', to: 'anime_online/dashboard#pingmedia_test_1', as: :pingmedia_test_1
    get 'pingmedia_test_2', to: 'anime_online/dashboard#pingmedia_test_2', as: :pingmedia_test_2
    get 'advertur_test', to: 'anime_online/dashboard#advertur_test', as: :advertur_test

    get "animes#{ani_manga_format}" => "animes_collection#index", klass: 'anime',
      with_video: '1', constraints: { page: /\d+/, studio: /[^\/]+/ }

    scope 'animes/:anime_id', module: 'anime_online' do
      get '' => redirect {|params, request| "#{request.url}/video_online" }

      resources :video_online, controller: 'anime_videos', except: [:show] do
        member do
          post :track_view
          post :viewed
        end

        collection do
          get :help
          get '(/:episode)(/:video_id)(/:all)', action: :index, as: :play,
            episode: /\d+/, video_id: /\d+/, all: /all/
          post :extract_url
          get :extract_url if Rails.env.development?
        end
      end
    end

    get 'pingmedia/iframe_240x400' => 'anime_online/pingmedia#iframe_240x400', as: :pingmedia_iframe_240x400
    get 'pingmedia/iframe_728x90' => 'anime_online/pingmedia#iframe_728x90', as: :pingmedia_iframe_728x90
    get 'pingmedia/iframe_240x400_advertur' => 'anime_online/pingmedia#iframe_240x400_advertur', as: :pingmedia_iframe_240x400_advertur
    get 'pingmedia/iframe_728x90_advertur' => 'anime_online/pingmedia#iframe_728x90_advertur', as: :pingmedia_iframe_728x90_advertur

    get 'robots.txt' => 'robots#anime_online'
  end

  constraints ShikimoriDomain do
    # main page
    resource :dashboards, only: [:show]

    # форум
    root to: 'topics#index'
    get '/', to: 'topics#index', as: :forum
    get '/', to: 'topics#index', as: :new_session

    # seo redirects
    get 'r' => redirect('/reviews')
    constraints other: /.*/  do
      get 'r/:other' => redirect { |params, request| "/reviews/#{params[:other]}" }
      get 'person/:other' => redirect { |params, request| "/people/#{params[:other]}" }
    end

    #constraints section: Section::VARIANTS do
    constraints section: /a|m|c|p|s|f|o|g|reviews|cosplay|v|all|news/, format: /html|json|rss/ do
      get ':section(/s-:linked)/new' => 'topics#new', as: :new_topic
      #get ':section(/s-:linked)/:topic/new' => 'topics#edit', as: :edit_section_topic

      get ':section(/s-:linked)(/p-:page)' => 'topics#index', as: :section
      #[:section_topic, :section_blog_post, :section_contest_comment].each do |name|
        #get ':section(/s-:linked)/:id' => 'topics#show', as: name
      #end
      get ':section(/s-:linked)/:id' => 'topics#show', as: :section_topic
    end
    resources :topics, only: [:create, :update, :destroy, :edit] do
      get 'reload/:is_preview' => :reload, as: :reload, is_preview: /true|false/, on: :member
    end

    get 'topics/chosen/:ids' => 'topics#chosen', as: :topics_chosen
    get 'topics/:id/tooltip(/:test)' => 'topics#tooltip', as: :topic_tooltip
    get 'entries/:id/tooltip(/:test)' => 'entries#tooltip', as: :entry_tooltip # это для совместимости, чтобы уже сформированные урлы не сломались

    # favourites
    post 'favourites/:linked_type/:linked_id' => 'favourites#create', as: :favourites
    delete 'favourites/:linked_type/:linked_id' => 'favourites#destroy'

    post 'favourites/seyu/:linked_type/:linked_id' => 'favourites#create', kind: Favourite::Seyu, as: :favourites_seyu
    delete 'favourites/seyu/:linked_type/:linked_id' => 'favourites#destroy', kind: Favourite::Seyu

    post 'favourites/producer/:linked_type/:linked_id' => 'favourites#create', kind: Favourite::Producer, as: :favourites_producer
    delete 'favourites/producer/:linked_type/:linked_id' => 'favourites#destroy', kind: Favourite::Producer

    post 'favourites/mangaka/:linked_type/:linked_id' => 'favourites#create', kind: Favourite::Mangaka, as: :favourites_mangaka
    delete 'favourites/mangaka/:linked_type/:linked_id' => 'favourites#destroy', kind: Favourite::Mangaka

    post 'favourites/person/:linked_type/:linked_id' => 'favourites#create', kind: Favourite::Person, as: :favourites_person
    delete 'favourites/person/:linked_type/:linked_id' => 'favourites#destroy', kind: Favourite::Person

    # рестарт джобы
    get "job/:id/restart" => 'jobs#restart', as: 'restart_job'

    resources :cosplay_galleries, only: [] do
      get :publishing, on: :collection
      post :publish, on: :member
    end

    resource :translations, only: [:show]

    resources :clubs do
      member do
        get :comments
        get :members
        get :animes
        get :mangas
        get :characters
        get :images
        post :upload
      end

      collection do
        get '/page/:page', action: :index, as: :page
      end

      resources :group_roles, only: [:create, :destroy], concerns: [:autocompletable]
      resources :group_invites, only: [:create]
    end

    resources :group_invites, only: [] do
      post :accept, on: :member
      post :reject, on: :member
    end
    resources :images, only: [:destroy]

    # statistics
    get 'anime-history' => 'statistics#index', as: :anime_history

    # site pages
    resources :pages, path: '/', only: [] do
      collection do
        get :ongoings
        get :about

        get :terms
        get :privacy
        get :user_agent

        get 'site-news' => :news, kind: 'site', format: :rss
        get 'anime-news' => :news, kind: 'anime', format: :rss

        get :disabled_registration
        get :disabled_openid
        get :tableau
      end
    end

    resource :moderations, only: [:show] do
      collection do
        get :missing_screenshots

        scope kind: /all|vk|vk_subbed|vk_dubbed|subbed|dubbed/ do
          get 'missing_videos(/:kind)' => :missing_videos, as: :missing_videos
          get 'missing_videos/:kind/episodes/:anime_id' => :missing_episodes, as: :missing_episodes
        end
      end
    end

    resource :tests, only: [:show] do
      get :momentjs
      get :border
      get 'd3/:anime_id' => :d3, as: :d3
      get :webm
      get :vk_video
      get :colors
      #get 'd3/:anime_id/data' => :d3_data, as: :d3_data, format: :json
    end

    # картинки с danbooru
    resources :danbooru, only: [], concerns: [:autocompletable] do
      constraints url: /.*/ do
        get 'yandere/:url' => :yandere, on: :collection
      end
    end

    # cosplay
    constraints id: /\d[^\/]*?/ do
      resources :cosplay, path: '/cosplay' do
        collection do
          get :mod
        end
        resources :cosplay_galleries, path: '', controller: 'cosplay' do
          get :delete
          get :undelete
        end
      end
    end

    # cosplayers
    get 'cosplay/:gallery/comments' => 'cosplayers#comments', as: :cosplay_comments
    get 'cosplay' => 'cosplayers#index', as: :cosplayers
    get 'cosplay/:cosplayer(/:gallery)' => 'cosplayers#show', as: :cosplayer

    resources :genres, only: [:index, :edit, :update] do
      get :tooltip, on: :member

      collection do
        get ':kind' => :index, as: :index, kind: /anime|manga/
      end
    end

    # tags
    #get 'tags/autocomplete/:search' => 'tags#autocomplete', as: :autocomplete_tags, format: :json

    # seo redirects
    constraints kind: /animes|mangas/, other: /.*/, other2: /.*/ do
      get ':kind/season/planned:other' => redirect { |params, request| "/#{params[:kind]}/status/anons#{params[:other]}" }
      get ':kind/season/ongoing:other' => redirect { |params, request| "/#{params[:kind]}/status/ongoing#{params[:other]}" }
      get ':kind/season/latest:other' => redirect { |params, request| "/#{params[:kind]}/status/latest#{params[:other]}" }
      get ':kind(:other)planned(:other2)' => redirect { |params, request| "#{params[:kind]}#{params[:other]}anons#{params[:other2]}" }
      constraints type: /Anime|translation_planned/ do
        get ':kind/type/:type:other' => redirect { |params, request| "/#{params[:kind]}#{params[:other]}" }
      end
    end

    # аниме и манга
    ['animes', 'mangas'].each do |kind|
      get "#{kind}#{ani_manga_format}" => "animes_collection#index", as: kind, klass: kind.singularize, constraints: { page: /\d+/, studio: /[^\/]+/ }
      get "#{kind}/menu(/rating/:rating)" => "animes_collection#menu", klass: kind.singularize, as: "menu_#{kind}"

      resources kind, only: [:show] do
        member do
          get :characters
          get :staff
          get :files
          get :similar
          get :screenshots
          get :videos
          get 'cosplay(/page/:page)' => :cosplay, as: :cosplay

          get :related
          get :chronology
          get :franchise

          get :art
          get :images
          get :clubs

          get :summaries

          # TODO: удалить после 2016-01-01
          get 'comments/reviews' => redirect { |params, request| request.url.sub 'comments/reviews', 'summaries' }


          get :other_names # другие названия
          get :resources # подгружаемый центральный блок с персонажами, скриншотами, видео

          get :stats
          get :recent

          # инфо по торрентам эпизодов
          get :episode_torrents

          get 'cosplay/:anything' => redirect { |params, request| "/#{kind}/#{params[:id]}/cosplay" }, anything: /.*/
        end

        # обзоры
        resources :reviews, type: kind.singularize.capitalize
      end
    end

    resources :user_rates, only: [:create, :edit, :update, :destroy] do
      get :edit_api => :edit, action: :edit, as: :edit_api, on: :member, api: true
      post :increment, on: :member
    end

    resources :animes, only: [:edit, :update] do
      concerns :db_entry, fields: /description|russian|name|kind|episodes|rating|screenshots|videos|torrents_name|tags|aired_on|released_on|genres/

      post 'torrent' => 'torrents#create', on: :member

      resources :screenshots, only: [:create, :destroy] do
        post :reposition, on: :collection
      end
      resources :videos, only: [:create, :destroy]
    end

    resources :mangas, only: [:edit, :update] do
      concerns :db_entry, fields: /name|russian|description|kind|rating|tags|volumes|chapters|aired_on|released_on|status|genres/
    end

    resources :characters, only: [:show, :edit, :update] do
      concerns :db_entry, fields: /name|russian|japanese|description|tags|japanese/
      concerns :searcheable

      member do
        get :seyu
        get :animes
        get :mangas
        get :art
        get :images
        get 'cosplay(/page/:page)' => :cosplay, as: :cosplay
        get :clubs
      end
    end

    resources :people, only: [:show, :edit, :update] do
      concerns :db_entry, fields: /name|russian|japanese|website|birthday/
      concerns :searcheable

      member do
        get 'time' => redirect {|params, request| request.url.sub('/time', '') } # редирект со старых урлов
        get 'works(order-by/:order_by)' => :works, order_by: /date/, as: :works
      end
    end
    get 'producers/search/:search(/page/:page)' => 'people#index', as: :search_producers, kind: 'producer', constraints: { page: /\d+/ }
    get 'mangakas/search/:search(/page/:page)' => 'people#index', as: :search_mangakas, kind: 'mangaka', constraints: { page: /\d+/ }

    resources :seyu, only: [:show, :edit, :update] do
      concerns :db_entry, fields: /name|russian|japanese|website|birthday/
      concerns :searcheable

      get :roles, on: :member
    end
    #get "people/:search(/page/:page)" => 'people#index', as: :people_search, constraints: { page: /\d+/ }
    #get "seyu/:id#{ani_manga_format}" => 'seyu#show', as: :seyu
    #get "mangaka/:id#{ani_manga_format}" => 'mangaka#show', as: :seyu

    # голосования
    resources :contests do
      get :current, on: :collection

      member do
        post :start
        post :build
        post :propose
        post :stop_propose
        post :cleanup_suggestions

        get :comments

        get :grid
        get 'rounds/:round', action: 'show', as: 'round'
        get 'rounds/:round/match/:match_id', action: 'show', as: 'round_match'
        get 'rounds/:round/match/:match_id/users', action: 'users', as: 'round_match_users'
      end

      resources :contest_suggestions, path: 'suggestions', only: [:show, :create, :destroy]
      resources :contest_matches, path: 'matches', only: [:show] do
        post 'vote/:variant' => 'contest_matches#vote', as: 'vote', on: :member
      end
    end

    # votes
    post 'votes/:type/:id/yes' => 'votes#create', voting: 'yes', as: :vote_yes
    post 'votes/:type/:id/no' => 'votes#create', voting: 'no', as: :vote_no

    get 'kakie-anime-postmotret' => 'recommendations#favourites', as: :recommendations_favourites_anime, action: :favourites, klass: Anime.name.downcase
    get 'kakuyu-mangu-pochitat' => 'recommendations#favourites', as: :recommendations_favourites_manga, action: :favourites, klass: Manga.name.downcase
    # recommendations
    if Rails.env.development?
      get "recommendations/test(/:users(/:threshold))(/user/:user)" => 'recommendations#test', defaults: { users: 10, threshold: 0 }
    end
    get "recommendations/:klass(/:metric(/:threshold))(/user/:user)/#{ani_manga_format}" => 'recommendations#index', as: :recommendations, klass: /anime|manga/, metric: /euclid|euclid_z|pearson|pearson_mean|pearson_z|svd|svd_z|svd_mean/, votes: /\d+/
    get "recommendations/anime" => 'recommendations#index', as: :recommendations_anime, klass: Anime.name.downcase
    get "recommendations/manga" => 'recommendations#index', as: :recommendations_manga, klass: Manga.name.downcase
    resources :recommendation_ignores, only: [:create] do
      constraints target_type: /anime|manga/ do
        delete 'cleanup/:target_type', action: :cleanup, on: :collection, as: :cleanup
      end
    end

    # userlist comparer
    get "comparer/:list_type/:user_1/vs/:user_2#{ani_manga_format}" => 'userlist_comparer#show',
      as: :userlist_comparer,
      constraints: {
        list_type: /anime|manga/,
        user_1: /[^\/]+?/,
        user_2: /[^\/]+?/,
        format: /json/
      }

    resources :studios, only: [:index]
    resources :proxies, only: [:index]

    # news
    get 'entries/:id' => 'entries#show', as: :entry_body, constraints: { format: /json/ }
    #get 'blogs' => 'entries#index', as: :blogs
    #get 'blogs(/:offset/:limit)' => 'entries#postloader', as: :blogs_postloader, constraints: { offset: /\d+/, limit: /\d+/ }
    get ':year/:month/:day/:id' => 'entries#show', as: :news, constraints: { year: /\d+/, day: /\d+/ }
    #patch 'blogs/:id' => 'entries#apply', as: :entry
    #delete 'blogs/:id' => 'entries#destroy'
    #get 'blogs/new' => 'entries#new', as: :new_entry
    #post 'blogs/create' => 'entries#create', as: :create_news

    get 'sitemap' => 'sitemap#index'
    get 'robots.txt' => 'robots#shikimori'

    authenticate :user, lambda { |u| u.admin? } do
      mount Sidekiq::Web, at: 'sidekiq'
      mount PgHero::Engine, at: 'pghero'
    end

    if Rails.env.development?
      get 'users/by-id/:user_id' => 'users#statistics', type: 'statistics', kind: 'anime'
    end

    resources :user_tokens, only: [:destroy]

    # users
    get 'users(/:similar/:klass/(:threshold))(/search/:search)(/page/:page)' => 'users#index', as: :users, page: /\d+/, similar: /similar/, klass: /anime|manga/
    post 'users/search' => 'users#search', as: :users_search

    # messages edit & rss & email bounce
    # create & preview урлы объявлены выше, глобально
    resources :messages, only: [:show, :edit, :update, :destroy] do
      collection do
        get 'chosen/:ids' => :chosen, as: :chosen

        post :mark_read
        post :bounce

        get ':name/:key.rss' => 'messages#feed', format: :rss, type: 'notifications', name: /[^\/]+?/, as: :feed
        get ':name/:key/Private/unsubscribe' => 'messages#unsubscribe', name: /[^\/]+?/, kind: MessageType::Private, as: :unsubscribe
      end
    end

    resources :profiles, path: '/', constraints: { id: /(?: [^\/.] (?! \.rss$) | [^\/] (?= \.) | \.(?! rss$) )+/x }, only: [:show, :update] do
      member do
        get :friends
        get :favourites
        get :clubs
        get :ban
        get :feed
        #get :stats
        get 'edit(/:page)' => :edit, as: :edit, page: /account|profile|password|styles|list|notifications|misc/

        get 'reviews(/page/:page)' => :reviews, as: :reviews
        get 'comments(/page/:page)(/search/:search)' => :comments, as: :comments
        scope 'comments' do
          get 'reviews(/page/:page)' => :summaries, as: :summaries
        end
        get 'versions(/page/:page)' => :versions, as: :versions
        get 'videos(/page/:page)' => :videos, as: :videos
      end

      get 'manga' => redirect {|params, request| request.url.sub('/manga', '') } # редирект со старых урлов
      get 'list/history' => redirect {|params, request| request.url.sub('/list/history', '/history') } # редирект со старых урлов
      resources :user_history, only: [], path: '/history' do
        collection do
          get '(:page)' => :index, as: :index
          delete 'reset/:type' => :reset, as: :reset, type: /anime|manga/
        end
      end

      resources :user_rates, only: [], path: '/list' do
        collection do
          get ":list_type#{ani_manga_format}" => :index, as: '', list_type: /anime|manga/
          get ':list_type/export' => :export, as: :export
          post :import
        end
      end

      resources :user_preferences, only: [] do
        patch :update, on: :collection
      end

      resources :dialogs, only: [:index, :show, :destroy] do
        member do
          get 'page/:page' => :show, as: :show
          get 'reply/:reply_message_id' => :show, as: :reply
        end
        get '(page/:page)' => :index, as: :index, on: :collection
      end

      resources :messages, only: [], messages_type: /news|notifications|private/ do
        collection do
          get ':messages_type(/page/:page)' => :index, as: :index
          post 'read/:messages_type/all' => :read_all, as: :read_all, messages_type: /news|notifications/
          post 'delete/:messages_type/all' => :delete_all, as: :delete_all, messages_type: /news|notifications/
        end
      end

      resources :achievements, only: [:index] do
        get :franchise, on: :collection
      end
    end

    #post 'subscriptions/:type/:id' => 'subscriptions#create', as: :subscribe
    delete 'subscriptions/:type/:id' => 'subscriptions#destroy', as: :subscribe

    get 'log_in/restore' => "admin_log_in#restore", as: :restore_admin
    get 'log_in/:nickname' => "admin_log_in#log_in", nickname: /.*/

    get '*a', to: 'pages#page404' unless Rails.env.development?
  end
end
