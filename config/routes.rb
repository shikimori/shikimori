Site::Application.routes.draw do
  constraints AnimeOnlineDomain  do
    root to: 'anime_online/anime_videos#index'
    get 'videos/:id(/:episode_id)(/:video_id)' => 'anime_online/anime_videos#show', as: :anime_videos_show, constraints: { episode_id: /\d+/, video_id: /\d+/ }
    get 'videos' => 'anime_online/anime_videos#index', as: :anime_videos
    post 'videos/:id/complaint/:kind' => 'anime_online/anime_videos#complaint', as: :anime_videos_complaint, constraints: { kind: /broken_video|wrong_video/ }
    get 'robots.txt' => 'robots#animeonline'
  end

  constraints ShikimoriDomain  do
    # форум
    root to: 'topics#index'
    get '/' => 'topics#index', as: :forum
    get '/' => 'topics#index', as: :new_session

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
    get '/users/auth/:action/callback(.:format)', as: :user_omniauth_callback, action: /facebook|vkontakte|twitter/, controller: "users/omniauth_callbacks" # |google_apps|yandex|google_oauth2

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
        get ':commentable_type/:commentable_id/:offset/:limit(/:reviews_only)', action: :postloader, as: :model
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
      delete 'changes/anime/:anime_id/lock' => 'user_changes#release_anime_lock', as: :anime_lock

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
    end

    # messages
    # TODO: refactor всё в resources :messages
    get 'messages' => redirect('messages/inbox')
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
      get 'members', on: :member, type: 'members'
      get 'settings', on: :member, type: 'settings'
      get 'images', on: :member, type: 'images'

      get 'animes', on: :member, type: 'animes'
      get 'mangas', on: :member, type: 'mangas'
      get 'characters', on: :member, type: 'characters'

      get 'translation/planned' => 'translation#planned', on: :member, as: :translation_planned, type: 'translation_planned'
      get 'translation/finished' => 'translation#finished', on: :member, as: :translation_finished, type: 'translation_finished'
    end
    put 'groups/:id' => 'groups#apply', as: :apply_group
    post 'groups/:id' => 'groups#apply', as: :apply_group
    get 'groups/:id/autocomplete/:search' => 'groups#autocomplete', as: 'autocomplete_group_members', format: :json, search: /.*/

    resources :user_images, only: [:create]
    resources :images do
      post ':model/:id/new', action: :new, on: :collection, as: :new
      post ':model/:id', action: :create, on: :collection, as: :create
      get 'original', action: :edit, on: :member, as: 'edit_original', original: true
      get 'raw', action: :raw, on: :member
    end
    post 'remote_upload' => 'images#remote_upload'
    #get 'remote_upload' => 'images#remote_upload'

    # join/leave
    post 'groups/:id/roles(/:user_id)' => 'group_roles#create', as: :group_roles
    delete 'groups/:id/roles(/:user_id)' => 'group_roles#destroy', as: :group_roles
    # invite
    post 'invites/:group_id/:nickname' => 'group_invites#create', as: :group_invites, nickname: /.*/
    put 'invites/:id/accept' => 'group_invites#accept', as: :group_invites_accept
    put 'invites/:id/reject' => 'group_invites#reject', as: :group_invites_reject

    # old forum
    get 'forums/section-:section/topic-:id(/page/:page)(/:unread)(.:format)' => 'topics_old#show'
    get 'forums/section-:id(/page/:page)(.:format)' => 'sections#show'
    get 'forums' => redirect('/')

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
    get "site-news" => 'pages#news', kind: 'site'
    get "anime-news" => 'pages#news', kind: 'anime'
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
      put 'characters/:id/apply' => 'characters#apply', as: :apply_character
      get 'characters/:id/:page' => 'characters#page', as: 'page_character', constraints: { page: /comments|images|cosplay/ }
      get 'characters/:id/cosplay/:gallery' => 'characters#page', page: 'cosplay', as: 'cosplay_character'
      get 'characters/:id/edit/:subpage' => "characters#edit", as: 'edit_character', page: 'edit', constraints: { subpage: /description|russian/ }
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
      match "#{plural}#{ani_manga_format}" => "ani_mangas_collection#index", as: plural, klass: singular, constraints: { page: /\d+/, studio: /[^\/]+/ }
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
          put 'apply'

          # работа со списком
          post 'rate' =>  'user_rates#create', type: klass.name
          put 'rate' => 'user_rates#update', type: klass.name
          delete 'rate' => 'user_rates#destroy', type: klass.name

          get ':page' => "#{plural}#page", as: 'page', page: /characters|similar|chronology|screenshots|videos|images|files|stats|recent/
          get 'edit/:subpage' => "#{plural}#edit", page: 'edit', as: 'edit', subpage: /description|russian|screenshot|videos|inks|torrents_name/

          get 'cosplay' => redirect { |params,request| "/#{plural}/#{params[:id]}/cosplay/all" }
          get 'cosplay/:character(/:gallery)' => "#{plural}#cosplay", page: 'cosplay', as: 'cosplay'
        end

        # обзоры
        resources :reviews, type: klass.name, controller: 'AniMangasController::Reviews'
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
        get 'cleanup/:target_type', action: :cleanup_warning, on: :collection, as: :cleanup
        delete 'cleanup/:target_type', action: :cleanup, on: :collection
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
    get "seyu/:id/(/:sort)" => 'seyu#show', as: :seyu, constraints: { id: /\d[^\/]*/, sort: /time/ }
    get "seyu/:search(/page/:page)" => 'seyu#index', as: :seyu_search, kind: 'seyu', constraints: { page: /\d+/ }, format: :json
    get "producer/:search(/page/:page)" => 'people#index', as: :producer_search, kind: 'producer', constraints: { page: /\d+/ }, format: :json
    get "mangaka/:search(/page/:page)" => 'people#index', as: :mangaka_search, kind: 'mangaka', constraints: { page: /\d+/ }, format: :json
    get "people/:search(/page/:page)" => 'people#index', as: :people_search, constraints: { page: /\d+/ }, format: :json
    #get "seyu/:id#{ani_manga_format}" => 'seyu#show', as: :seyu
    #get "mangaka/:id#{ani_manga_format}" => 'mangaka#show', as: :seyu

    # studios
    get "studios" => 'studios#index', as: :studios
    put "studios/:id/apply" => 'studios#apply', as: :apply_studio
    get "studios/:id#{ani_manga_format}" => 'pages#page404', as: :studio

    # proxies
    get 'proxies' => 'proxies#index'

    # news
    get 'entries/:id' => 'entries#show', as: :entry_body, constraints: { format: /json/ }
    #get 'blogs' => 'entries#index', as: :blogs
    #get 'blogs(/:offset/:limit)' => 'entries#postloader', as: :blogs_postloader, constraints: { offset: /\d+/, limit: /\d+/ }
    get ':year/:month/:day/:id' => 'entries#show', as: :news, constraints: { year: /\d+/, day: /\d+/ }
    #put 'blogs/:id' => 'entries#apply', as: :entry
    #delete 'blogs/:id' => 'entries#destroy'
    #get 'blogs/new' => 'entries#new', as: :new_entry
    #post 'blogs/create' => 'entries#create', as: :create_news

    get 'sitemap' => 'sitemap#index'
    get 'robots.txt' => 'robots#shikimori'
    apipie
    namespace :api, defaults: { format: 'json' } do
      scope module: :v1 do
        resources :comments, only: [:show, :index]
        resource :authenticity_token, only: [:show]

        devise_scope :user do
          resources :sessions, only: [:create]
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

      resources :animes, only: [:index, :show]
      resources :genres, only: [:index]
      resources :studios, only: [:index]
      resources :user_rates, only: [:index]
      resources :reviews, only: [:show]
    end

    if Rails.env.development?
      get 'users/by-id/:user_id' => 'users#statistics', type: 'statistics', kind: 'anime'
    end

    # users
    get 'users(/:similar/:klass/(:threshold))(/:search)(/page/:page)' => 'users#index', as: :users, page: /\d+/, similar: /similar/, klass: /anime|manga/
    post 'users/search' => 'users#search', as: :users_search
    get 'users/autocomplete/:search' => 'users#autocomplete', as: :autocomplete_users, format: :json

    constraints id: /[^\/]+?/, format: /json|rss/ do
      get ':id(/:kind)' => 'users#statistics', as: :user, type: 'statistics', kind: /anime|manga/
      get ':id/settings' => 'users#settings', as: :user_settings, type: 'settings'
      #get ':id/blog' => 'users#topics', as: :user_topics, type: 'topics'
      #get ':id/reply/:comment_id' => 'users#show', as: :reply_to_user, type: 'profile'
      put ':id/settings' => 'users#update', as: :edit_user
      get ':id/ban' => 'users#ban', as: :ban_user, type: 'ban'
      post ':id/ban' => 'users#do_ban'

      get ':id/comments(/page/:page)' => 'users#comments', as: :user_comments, type: 'comments'
      get ':id/reviews(/page/:page)' => 'users#reviews', as: :user_reviews, type: 'reviews'
      get ':id/changes(/page/:page)' => 'users#changes', as: :user_changes, type: 'changes'

      get ':id/friends' => 'users#friends', as: :user_friends, type: 'friends'
      get ':id/clubs' => 'users#clubs', as: :user_clubs, type: 'clubs'
      put ':id/contacts_privacy' => 'users#contacts_privacy', as: :user_contacts_privacy
      get ':id/favourites' => 'users#favourites', as: :user_favourites, type: 'favourites'

      # user_list
      constraints list_type: /anime|manga/ do
        get ":id/list/:list_type#{ani_manga_format}" => 'user_lists#show', as: :ani_manga_filtered_list
        get ":id/list/:list_type.xml" => 'user_lists#export', format: :xml, as: :ani_manga_export
        get ':id/list/:list_type(-:list_type_kind)' => 'user_lists#show', as: :ani_manga_list,
                                                                          constraints: {list_type_kind: /plan-to-watch|watching|completed|on-hold|dropped/ }
      end
      post ':id/import' => 'user_lists#list_import', as: :list_import
      get ":id/list/history(/page/:page)" => 'user_lists#history', as: :list_history, type: 'list-history', constraints: { page: /\d+/ }

      get ':id/talk(/:target)(/page/:page)(/comment/:comment_id)(/message/:message_id)' => 'messages#talk', as: :talk, type: 'talk'
      #get ':id/message' => 'messages#new', as: :private_message
      get ':id/provider/:provider' => 'users#remove_provider', as: :user_remove_provider
    end

    constraints type: /anime|manga/ do
      get 'list/:type/cleanup' =>  'user_rates#cleanup_warning', as: :list_cleanup
      delete 'list/:type/cleanup' =>  'user_rates#cleanup', as: :list_cleanup
    end

    post 'subscriptions/:type/:id' => 'subscriptions#create', as: :subscribe
    delete 'subscriptions/:type/:id' => 'subscriptions#destroy'

    get 'log_in/restore' => "admin_log_in#restore", as: :restore_admin
    get 'log_in/:nickname' => "admin_log_in#log_in", nickname: /.*/

    if Rails.env.test?
      match 'subscriptions/:action', controller: :subscriptions
      match 'messages', controller: :messages, as: :messages
      match 'users(/:action(/:id(.:format)))', controller: :users
    end
    match 'animes(/:action(/:id(.:format)))', controller: :animes
    match 'mangas(/:action(/:id(.:format)))', controller: :mangas
    match 'groups(/:action(/:id(.:format)))', controller: :groups
    match 'invites(/:action(/:id(.:format)))', controller: :group_invites

    mount_sextant if Rails.env.development?
    match '*a', to: 'pages#page404'
  end
end
