require 'sidekiq/web'

Site::Application.routes.draw do
  constraints AnimeOnlineDomain do
    get '/', to: 'anime_online/anime_videos#index'
    namespace :anime_online do
      resources :anime, only: [:show] do
        resources :anime_videos, only: [:new, :create] do
          get :viewed, on: :member
        end
      end

      resource :anime_videos do
        get :help, on: :member
      end

      post 'anime_videos/:id/rate' => 'anime_videos#rate', as: :rate_anime
    end

    get 'videos(/search/:search)(/page/:page)' => 'anime_online/anime_videos#index', as: :anime_videos
    post 'videos/extract_url' => 'anime_online/anime_videos#extract_url', as: :anime_videos_extract_url
    get 'videos/:id(/:episode)(/:video_id)(/:all)' => 'anime_online/anime_videos#show', as: :anime_videos_show, constraints: { episode: /\d+/, video_id: /\d+/, all: 'all' }
    post 'videos/search' => 'anime_online/anime_videos#search', as: :anime_videos_search
    post 'videos/:id/report/:kind' => 'anime_online/anime_videos#report', as: :anime_videos_report, constraints: { kind: /broken|wrong/ }
    delete 'videos/:id' => 'anime_online/anime_videos#destroy', as: :delete_anime_videos
    get 'pingmedia/google' => 'anime_online/pingmedia#google'
    get 'pingmedia/google_leaderboard' => 'anime_online/pingmedia#google_leaderboard'
    get 'robots.txt' => 'robots#animeonline'
  end

  constraints ShikimoriDomain do
    # форум
    root to: 'topics#index'
    get '/', to: 'topics#index', as: :forum
    get '/', to: 'topics#index', as: :new_session

    # seo redirects
    get 'r' => redirect('/reviews')
    constraints other: /.*/  do
      get 'r/:other' => redirect { |params,request| "/reviews/#{params[:other]}" }
    end

    constraints section: /a|m|c|s|f|o|g|reviews|v|all|news/ do
      get ':section(/s-:linked)/new' => 'topics#new', as: :new_topic
      #get ':section(/s-:linked)/:topic/new' => 'topics#edit', as: :edit_section_topic

      get ':section/block' => 'forum#site_block', as: :forum_site_block

      get ':section(/s-:linked)(/p-:page)' => 'topics#index', as: :section
      [:section_topic, :section_blog_post, :section_contest_comment].each do |name|
        get ':section(/s-:linked)/:topic' => 'topics#show', as: name
      end
    end
    resources :topics, only: [:create, :update, :destroy, :edit]

    get 'comments/chosen/:ids(/:order)' => 'comments#chosen', as: :comments_chosen
    get 'topics/chosen/:ids' => 'topics#chosen', as: :topics_chosen
    get 'topics/:id/tooltip(/:test)' => 'topics#tooltip', as: :topic_tooltip
    get 'entries/:id/tooltip(/:test)' => 'entries#tooltip', as: :entry_tooltip # это для совместимости, чтобы уже сформированные урлы не сломались

    #get 'appear/read/:ids' => 'appear#read'
    post 'appear/read' => 'appear#read', as: :appear

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

    # верхний блок с инфой о логине пользователя
    get 'userbox' => 'site#userbox'

    # френд реквесты
    post ':id/friend' => 'friends#create', as: :friend_add
    delete ':id/friend' => 'friends#destroy', as: :friend_remove
    # игнор лист
    post ':id/ignore' => 'ignores#create', as: :ignore_add
    delete ':id/ignore' => 'ignores#destroy', as: :ignore_remove

    get 'users/sign_in' => redirect('/')

    devise_for :users, controllers: {
      omniauth_callbacks: 'users/omniauth_callbacks',
      registrations: 'users/registrations',
      passwords: 'users/passwords'
    }

    # комментарии
    resources :comments do
      post :raw
      resources :bans, only: [:new], controller: 'moderation/bans'

      resources :abuse_requests, controller: 'moderation/abuse_requests', only: [] do
        resources :bans, only: [:new], controller: 'moderation/bans'

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
        get 'fetch/:id/:topic_id/:skip/:limit' => 'comments#fetch', as: :fetch
        get ':commentable_type/:commentable_id/:offset/:limit(/:review)', action: :postloader, as: :model
      end
    end

    namespace :moderation do
      # TODO: refactor to resource
      get 'changes(/page/:page)' => 'user_changes#index', as: :users_changes

      get 'changes/:id/take' => 'user_changes#apply', as: :take_user_change, notify: true, taken: true
      get 'changes/:id/apply' => 'user_changes#apply', as: :aplly_user_change, notify: true
      get 'changes/:id/deny' => 'user_changes#deny', as: :deny_user_change, notify: true
      get 'changes/:id/delete' => 'user_changes#deny', as: :delete_user_change, notify: false
      post 'changes/anime/:anime_id/lock' => 'user_changes#get_anime_lock', as: :anime_lock
      delete 'changes/anime/:anime_id/lock' => 'user_changes#release_anime_lock'

      post 'changes/do' => 'user_changes#change', as: :do_user_change
      get 'changes/:id/tooltip(/:test)' => 'user_changes#tooltip', as: :user_change_tooltip
      get 'changes/:id' => 'user_changes#show', as: :user_change

      resources :bans, only: [:create, :index] do
        get '/page/:page', action: :index, as: :page, on: :collection
      end
      resources :abuse_requests, only: [:index] do
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

      resources :anime_video_reports, only: [:index] do
        get '/page/:page', action: :index, as: :page, on: :collection

        member do
          get :accept
          get :reject
          get :work
          get :cancel
        end
      end
    end

    # messages
    # TODO: refactor всё в resources :messages
    get 'messages' => redirect('messages/inbox'), as: :root_messages
    get 'messages/:id' => 'messages#show', constraints: { id: /\d+/ }
    constraints type: /inbox|sent|notifications|news/ do
      get 'messages/:type' => 'messages#index', as: :messages
      get 'messages/:type/:page' => 'messages#list', as: :messages_list, constraints: { page: /\d+/ }
    end
    get 'messages/:name/:key.rss' => 'messages#feed', format: :rss, type: 'notifications', name: /[^\/]+?/, as: :rss_notifications
    get 'messages/:name/:key/Private/unsubscribe' => 'messages#unsubscribe', name: /[^\/]+?/, kind: MessageType::Private, as: :messages_unsubscribe

    post 'messages/create' => 'messages#create', as: :create_messages
    resources :messages do
      post :bounce, on: :collection
    end
    post 'messages/read' => 'messages#read', read: true, as: :read_messages
    post 'messages/unread' => 'messages#read', read: false, as: :unread_messages

    # translation
    #get 'translation' => 'translation#index'
    get 'animes/translate' => redirect('/translation')
    get 'translation' => redirect('/clubs/2/translation/planned')

    # groups
    get 'groups' => redirect('/clubs')
    get 'groups/:id' => redirect('/clubs/%{id}'), as: :group
    post 'groups' => 'groups#create'

    resources :clubs, controller: :groups, except: [:create] do
      #get 'groups' => 'groups#index'
      #get 'groups/new' => 'groups#new', as: 'new_group'
      #get 'groups/:id' => 'groups#show', as: 'group', type: 'info'
      collection do
        get '/page/:page', action: :index, as: :page
      end
      member do
        get 'members', type: 'members'
        get 'settings', type: 'settings'
        get 'images', type: 'images'

        get 'animes', type: 'animes'
        get 'mangas', type: 'mangas'
        get 'characters', type: 'characters'
      end

      get 'translation/planned' => 'translation#planned', on: :member, as: :translation_planned, type: 'translation_planned'
      get 'translation/finished' => 'translation#finished', on: :member, as: :translation_finished, type: 'translation_finished'
    end
    patch 'groups/:id' => 'groups#apply', as: :apply_group
    post 'groups/:id' => 'groups#apply'
    get 'groups/:id/autocomplete/:search' => 'groups#autocomplete', as: 'autocomplete_group_members', format: :json, search: /.*/

    resources :user_images, only: [:create]
    resources :images do
      post ':model/:id/new', action: :new, on: :collection, as: :new
      post ':model/:id', action: :create, on: :collection, as: :create
      get 'original', action: :edit, on: :member, as: 'edit_original', original: true
      get 'raw', action: :raw, on: :member
    end

    # join/leave
    post 'groups/:id/roles(/:user_id)' => 'group_roles#create', as: :group_roles
    delete 'groups/:id/roles(/:user_id)' => 'group_roles#destroy'
    # invite
    post 'invites/:group_id/:nickname' => 'group_invites#create', as: :group_invites, nickname: /.*/
    patch 'invites/:id/accept' => 'group_invites#accept', as: :group_invites_accept
    patch 'invites/:id/reject' => 'group_invites#reject', as: :group_invites_reject

    # statistics
    get 'anime-history' => 'statistics#index', as: :anime_history

    # site pages
    get 'welcome_gallery' => 'pages#welcome_gallery'
    get 'user_agreement' => 'pages#user_agreement'
    get 'user_agent' => 'pages#user_agent'
    get 'redisign' => 'pages#redisign'
    get 'ongoings' => 'pages#calendar'
    get 'about' => 'pages#about'
    get 'page404' => 'pages#page404'
    get 'page503' => 'pages#page503'
    get 'apanel' => 'pages#admin_panel'
    get 'test' => 'pages#test'
    get 'raise-exception' => 'pages#raise_exception'
    get 'auth_form' => 'pages#auth_form'
    get "site-news" => 'pages#news', kind: 'site', format: :rss
    get "anime-news" => 'pages#news', kind: 'anime', format: :rss
    get "feedback" => 'pages#feedback'
    get 'disabled_registration' => 'pages#disabled_registration'
    get 'disabled_openid' => 'pages#disabled_openid'
    get 'tableau' => 'pages#tableau'

    # картинки с danbooru
    get 'd/autocomplete/:search' => 'danbooru#autocomplete', as: :autocomplete_danbooru_tags, format: :json
    constraints url: /.*/ do
      get "d/:md5/:url" => 'danbooru#show'
      get "y/:url" => 'danbooru#yandere'
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

    # characters
    get 'characters/autocomplete/:search' => 'characters#autocomplete', as: :autocomplete_characters, format: :json, search: /.*/
    get 'characters/:id/tooltip(/:test)' => 'characters#tooltip', as: :character_tooltip # это должно идти перед character_path
    constraints id: /\d[^\/]*?/ do
      get 'characters/:id' => 'characters#show', as: :character, page: 'info'
      patch 'characters/:id/apply' => 'characters#apply', as: :apply_character
      get 'characters/:id/:page' => 'characters#page', as: :page_character, constraints: { page: /comments|images|cosplay/ }
      get 'characters/:id/cosplay/:gallery' => 'characters#page', page: 'cosplay', as: 'cosplay_character'
      get 'characters/:id/edit/:subpage' => "characters#edit", as: :edit_character, page: 'edit', constraints: { subpage: /description|russian/ }
    end
    get "characters/:search(/page/:page)" => 'characters#index', as: :character_search, page: /\d+/
    # tags
    get 'tags/autocomplete/:search' => 'tags#autocomplete', as: :autocomplete_tags, format: :json

    # seo redirects
    constraints kind: /animes|mangas/, other: /.*/ do
      get ':kind/season/planned:other' => redirect { |params,request| "/#{params[:kind]}/status/planned#{params[:other]}" }
      get ':kind/season/ongoing:other' => redirect { |params,request| "/#{params[:kind]}/status/ongoing#{params[:other]}" }
      get ':kind/season/latest:other' => redirect { |params,request| "/#{params[:kind]}/status/latest#{params[:other]}" }
      constraints type: /Anime|translation_planned/ do
        get ':kind/type/:type:other' => redirect { |params,request| "/#{params[:kind]}#{params[:other]}" }
      end
    end

    # аниме и манга
    ani_manga_format = '(/type/:type)(/status/:status)(/season/:season)(/genre/:genre)(/studio/:studio)(/publisher/:publisher)(/duration/:duration)(/rating/:rating)(/options/:options)(/mylist/:mylist)(/search/:search)(/order-by/:order)(/page/:page)(.:format)'
    [:animes, :mangas].each do |kind|
      singular = kind.to_s.singularize
      klass = singular.camelize.constantize
      plural = kind.to_s

      #match "#{plural}/season/:season" => "ani_mangas_collection#season", as: plural, klass: singular, season: /\w+_\d+/ if kind == :animes
      get "#{plural}#{ani_manga_format}" => "ani_mangas_collection#index", as: plural, klass: singular, constraints: { page: /\d+/, studio: /[^\/]+/ }
      get "#{plural}/menu(/rating/:rating)(/nosort/:nosort)" => "ani_mangas_collection#menu", klass: singular, as: "menu_#{plural}"

      resources plural, defaults: { page: 'info' } do
        collection do
          get 'autocomplete/:search', action: :autocomplete, as: :autocomplete, format: :json, search: /.*/
        end

        member do
          # связанные
          get 'related/all', action: :related_all
          # другие названия
          get 'names/other', action: :other_names, as: :other_names
          # инфо по торрентам эпизодов
          get 'episode_torrents'
          # тултип
          get 'tooltip(/:test)', action: :tooltip, as: :tooltip
          # редактирование
          patch 'apply'

          # работа со списком
          post 'rate' =>  'user_rates#create', type: klass.name
          patch 'rate' => 'user_rates#update', type: klass.name
          delete 'rate' => 'user_rates#destroy', type: klass.name

          get ':page' => "#{plural}#page", as: 'page', page: /characters|similar|chronology|screenshots|videos|images|files|stats|recent/
          get 'edit/:subpage' => "#{plural}#edit", page: 'edit', as: 'edit', subpage: /description|russian|screenshot|videos|inks|torrents_name/

          get 'cosplay' => redirect { |params,request| "/#{plural}/#{params[:id]}/cosplay/all" }, as: :root_cosplay
          get 'cosplay/:character(/:gallery)' => "#{plural}#cosplay", page: 'cosplay', as: :cosplay
        end

        # обзоры
        resources :reviews, type: klass.name, controller: 'ani_mangas_controller/reviews'
      end
    end
    # удаление скриншота
    delete 'screenshot/:id' => 'screenshots#destroy', as: 'screenshot'
    delete 'video/:id' => 'videos#destroy', as: 'video'

    resources :animes do
      member do
        post 'torrent' => 'torrents#create'
        get ':type.rss' => 'animes#rss', as: 'rss', constraints: { type: /torrents|torrents_480p|torrents_720p|torrents_1080p/ }
        get 'subtitles/:group.rss' => 'animes#rss', as: 'subtitles', type: 'subtitles'

        resource :screenshots, only: [:create]
        resource :videos, only: [:create]
      end
    end

    # голосования
    resources :contests do
      collection do
        get :current
      end
      member do
        post :start
        post :build
        post :propose
        post :stop_propose

        get :grid
        get 'rounds/:round', action: 'show', as: 'round'
        get 'rounds/:round/match/:match_id', action: 'show', as: 'round_match'
        get 'rounds/:round/match/:match_id/users', action: 'users', as: 'round_match_users'
      end

      resources :contest_suggestions, path: 'suggestions', only: [:show, :create, :destroy]
      resources :contest_matches, path: 'matches' do
        member do
          post 'vote/:variant' => 'contest_matches#vote', as: 'vote'
        end
      end
    end

    resources :genres, only: [:index, :edit, :update] do
      get :tooltip, on: :member
    end

    # votes
    post 'votes/:type/:id/yes' => 'votes#create', voting: 'yes', as: :vote_yes
    post 'votes/:type/:id/no' => 'votes#create', voting: 'no', as: :vote_no

    # recommendations
    if Rails.env.development?
      get "recommendations/test(/:users(/:threshold))(/user/:user)" => 'recommendations#test', defaults: { users: 10, threshold: 0 }
    end
    get "recommendations/:klass(/:metric(/:threshold))(/user/:user)/#{ani_manga_format}" => 'recommendations#index', as: :recommendations, klass: /anime|manga/, metric: /euclid|pearson|pearson_mean|pearson_z|svd/, votes: /\d+/
    get "recommendations/anime" => 'recommendations#index', as: :recommendations_anime, klass: Anime.name.downcase
    get "recommendations/manga" => 'recommendations#index', as: :recommendations_manga, klass: Manga.name.downcase
    resources :recommendation_ignores, only: [:create] do
      constraints target_type: /anime|manga/ do
        delete 'cleanup/:target_type', action: :cleanup, on: :collection, as: :cleanup
      end
    end

    # userlist comparer
    get "comparer/:list_type/:user_1/vs/:user_2#{ani_manga_format}" => 'userlist_comparer#show', as: :userlist_comparer,
                                                                                                constraints: {
                                                                                                  list_type: /anime|manga/,
                                                                                                  user_1: /[^\/]+?/,
                                                                                                  user_2: /[^\/]+?/,
                                                                                                  format: /json/
                                                                                                }

    # people
    #post "person/:id/apply" => 'people#apply', as: :apply_person
    get 'people/autocomplete(/:kind)/:search' => 'people#autocomplete', as: :autocomplete_people, format: :json
    get 'person/:id/tooltip(/:test)' => 'people#tooltip', as: :person_tooltip # это должно идти перед person_path
    get "person/:id/(/:sort)" => 'people#show', as: :person, constraints: { id: /\d[^\/]*/, sort: /time/ }
    get "seyu/:id/(/:sort)(/:direct)" => 'seyu#show', as: :seyu, constraints: { id: /\d[^\/]*/, sort: /time/, direct: /direct/ }
    get "seyu/:search(/page/:page)" => 'seyu#index', as: :seyu_search, kind: 'seyu', constraints: { page: /\d+/ }
    get "producer/:search(/page/:page)" => 'people#index', as: :producer_search, kind: 'producer', constraints: { page: /\d+/ }
    get "mangaka/:search(/page/:page)" => 'people#index', as: :mangaka_search, kind: 'mangaka', constraints: { page: /\d+/ }
    get "people/:search(/page/:page)" => 'people#index', as: :people_search, constraints: { page: /\d+/ }
    #get "seyu/:id#{ani_manga_format}" => 'seyu#show', as: :seyu
    #get "mangaka/:id#{ani_manga_format}" => 'mangaka#show', as: :seyu

    # studios
    get "studios" => 'studios#index', as: :studios
    patch "studios/:id/apply" => 'studios#apply', as: :apply_studio
    get "studios/:id#{ani_manga_format}" => 'pages#page404', as: :studio

    # proxies
    get 'proxies' => 'proxies#index'

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
      mount Sidekiq::Web => '/sidekiq'
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
          end
        end
        resources :mangas, only: [:show, :index] do
          member do
            get :roles
            get :similar
            get :related
          end
        end

        resources :characters, only: [:show]
        resources :people, only: [:show]

        resources :studios, only: [:index]
        resources :genres, only: [:index]
        resources :publishers, only: [:index]

        resources :sections, only: [:index]
        resources :topics, only: [:index, :show]
        resources :comments, only: [:show, :index]

        resources :clubs, only: [:show, :index] do
          member do
            get :members
            get :animes
            get :mangas
            get :characters
            get :images
          end
        end

        resources :user_rates, only: [:create, :update, :destroy] do
          member do
            post :increment
          end
          collection do
            scope ':type', type: /anime|manga/ do
              delete :cleanup
              delete :reset
            end
          end
        end

        resource :authenticity_token, only: [:show]

        devise_scope :user do
          resources :sessions, only: [:create]
        end

        resources :users, only: [:index, :show] do
          collection do
            get :whoami
          end
          member do
            get :friends
            get :clubs
            get :favourites
            get :messages
            get :unread_messages
            get :history
            get :anime_rates
            get :manga_rates
          end
        end
        namespace :profile do
          resources :friends, only: [:index]
          resources :clubs, only: [:index]
          resources :favourites, only: [:index]
          resources :messages, only: [:index] do
            get :unread, on: :collection
          end
          resources :history, only: [:index, :show]
        end
      end
    end

    if Rails.env.development?
      get 'users/by-id/:user_id' => 'users#statistics', type: 'statistics', kind: 'anime'
    end

    # users
    get 'users(/:similar/:klass/(:threshold))(/:search)(/page/:page)' => 'users#index', as: :users, page: /\d+/, similar: /similar/, klass: /anime|manga/
    post 'users/search' => 'users#search', as: :users_search
    get 'users/autocomplete/:search' => 'users#autocomplete', as: :autocomplete_users, format: :json

    resources :profiles, constraints: { id: /[^\/]+?/ }, format: /json|rss/, only: [:show] do
      member do
        get '/settings(/:page)', page: /account|profile|password|styles|list|notifications|misc/, action: :settings
      end
    end

    constraints id: /[^\/]+?/, format: /json|rss/ do
      get ':id(/:kind)' => 'users#statistics', as: :user, type: 'statistics', kind: /anime|manga/
      get ':id/settings(/:page)' => 'users#settings', as: :user_settings, page: /account|profile|password|styles|list|notifications|misc/, type: 'settings'
      #get ':id/blog' => 'users#topics', as: :user_topics, type: 'topics'
      #get ':id/reply/:comment_id' => 'users#show', as: :reply_to_user, type: 'profile'
      patch ':id(/:type/:page)' => 'users#update'
      patch ':id/preferences' => 'user_preferences#update', as: :update_user_preferences, type: 'settings'
      patch ':id/password' => 'users#update_password', as: :update_user_password
      get ':id/ban' => 'users#ban', as: :ban_user, type: 'ban'
      post ':id/ban' => 'users#do_ban'

      get ':id/comments(/page/:page)' => 'users#comments', as: :user_comments, type: 'comments'
      get ':id/reviews(/page/:page)' => 'users#reviews', as: :user_reviews, type: 'reviews'
      get ':id/changes(/page/:page)' => 'users#changes', as: :user_changes, type: 'changes'

      get ':id/friends' => 'users#friends', as: :user_friends, type: 'friends'
      get ':id/clubs' => 'users#clubs', as: :user_clubs, type: 'clubs'
      patch ':id/contacts_privacy' => 'users#contacts_privacy', as: :user_contacts_privacy
      get ':id/favourites' => 'users#favourites', as: :user_favourites, type: 'favourites'

      # user_list
      constraints list_type: /anime|manga/ do
        get ":id/list/:list_type#{ani_manga_format}" => 'user_lists#show', as: :ani_manga_list
        get ":id/list/:user_rate_id/edit" => 'user_lists#edit', as: :user_list_edit
        get ':id/list/:list_type.xml' => 'user_lists#export', format: :xml, as: :ani_manga_export
      end
      post ':id/import' => 'user_lists#list_import', as: :list_import
      get ":id/list/history(/page/:page)" => 'user_lists#history', as: :list_history, type: 'list_history', constraints: { page: /\d+/ }

      get ':id/talk(/:target)(/page/:page)(/comment/:comment_id)(/message/:message_id)' => 'messages#talk', as: :talk, type: 'talk'
      #get ':id/message' => 'messages#new', as: :private_message
      get ':id/provider/:provider' => 'users#remove_provider', as: :user_remove_provider
    end

    post 'subscriptions/:type/:id' => 'subscriptions#create', as: :subscribe
    delete 'subscriptions/:type/:id' => 'subscriptions#destroy'

    get 'log_in/restore' => "admin_log_in#restore", as: :restore_admin
    get 'log_in/:nickname' => "admin_log_in#log_in", nickname: /.*/

    if Rails.env.test?
      get 'users(/:action(/:id(.:format)))', controller: :users
      resources :user_preferences, only: [:update]
      get 'groups(/:action(/:id(.:format)))', controller: :groups
      get 'characters(/:action(/:id(.:format)))', controller: :characters
      get 'comments(/:action(/:id(.:format)))', controller: :comments
      get 'pages(/:action(/:id(.:format)))', controller: :pages
      get 'danbooru(/:action(/:id(.:format)))', controller: :danbooru
    end

    get '*a', to: 'pages#page404' unless Rails.env.development?
  end
end
