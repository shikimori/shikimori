# TODO: отрефакторить толстый контроллер
# TODO: спеки на все методы контроллера
class MessagesController < UsersController
  alias :super_show :show

  @@limit = 15

  DISABLED_NOTIFICATIONS = User::MY_EPISODE_MOVIE_NOTIFICATIONS + User::MY_EPISODE_OVA_NOTIFICATIONS +
    User::NOTIFICATIONS_TO_EMAIL_SIMPLE + User::NOTIFICATIONS_TO_EMAIL_GROUP + User::NOTIFICATIONS_TO_EMAIL_NONE# +
    #User::PRIVATE_MESSAGES_TO_EMAIL

  DISABLED_CHECKED_NOTIFICATIONS = User::NOTIFICATIONS_TO_EMAIL_GROUP# + User::PRIVATE_MESSAGES_TO_EMAIL

  before_filter :prepare, only: [ ]
  #before_filter :authenticate_user!, exept: [:feed, :unsubscribe]
  before_filter :authenticate_user!, only: [:index, :show, :list, :talk, :create, :destroy, :read]

  # отображение страницы личных сообщений
  def index
    @user ||= current_user

    @page_title ||= case params[:type]
      when 'inbox' then UsersController.profile_title('Личные сообщения', @user)
      when 'news' then UsersController.profile_title('Новости сайта', @user)
      when 'notifications' then UsersController.profile_title('Уведомления сайта', @user)
      when 'sent' then UsersController.profile_title('Отправленные сообщения', @user)
    end

    @page = (params[:page] || 1).to_i
    @messages = MessagesQuery.new(current_user, params[:type]).fetch @page, @@limit
    @add_postloader = @messages.size > @@limit
    @messages = @messages.take(@@limit)

    @postloader_url = messages_list_url(page: @page+1, format: :json)

    respond_to do |format|
      format.html { super_show }
      format.json do
        render json: {
          content: render_to_string(partial: 'messages/messages', layout: false, formats: :html),
          title_page: @page_title,
          counts: unread_counts
        }
      end
    end
  end

  # rss лента сообщений
  def feed
    @user = User.find_by_nickname(User.param_to params[:name])
    raise NotFound.new('user not found') if @user.nil?
    raise NotFound.new('wrong rss key') if rss_key(@user) != params[:key]

    @messages = Rails.cache.fetch("notifications_feed_#{@user.id}", expires_in: 60.minutes) do
      Message.where({
        src_type: User.name,
        dst_type: User.name,
        dst_id: @user.id,
      })
      .where { kind.not_eq(MessageType::Private) }
      .order('`read`, created_at desc')
      .includes(:linked)
      .limit(25)
      .all
    end.map do |message|
      linked = message.linked && message.linked.respond_to?(:linked) && message.linked.linked ? message.linked.linked : nil
      {
        entry: message,
        guid: message.guid,
        image_url: linked && linked.image.exists? ? 'http://shikimori.org' + linked.image.url(:preview, false) : nil,
        link: linked ? url_for(linked) : messages_url(type: :notifications),
        linked_name: linked ? linked.name : nil,
        pubDate: Time.at(message.created_at.to_i).to_s(:rfc822),
        title: linked ? linked.name : 'Сайт'
      }
    end
  end

  # отписка от емайлов о сообщениях
  def unsubscribe
    @user = User.find_by_nickname(User.param_to params[:name])
    raise Forbidden if @user.nil?
    raise Forbidden if unsubscribe_key(@user, params[:kind]) != params[:key]

    if @user.notifications & User::PRIVATE_MESSAGES_TO_EMAIL != 0
      @user.update_attribute(:notifications, @user.notifications - User::PRIVATE_MESSAGES_TO_EMAIL)
    end
  end

  # отображение сообщения
  def show
    @message = Message.includes(:src).includes(:dst).find(params[:id])
    raise NotFound.new('access denied') unless @message.src_id == current_user.id || @message.dst_id == current_user.id

    respond_to do |format|
      format.html { render partial: 'comments/comment', layout: false, locals: { comment: @message }, formats: :html }
      format.json { render json: { user: @message.user.nickname, body: @message.body } }
    end
  end

  # список сообщений
  def list
    @page = (params[:page] || 1).to_i
    @messages = MessagesQuery.new(current_user, params[:type]).fetch @page, @@limit
    add_postloader = @messages.size > @@limit
    @messages = @messages.take(@@limit)

    render json: {
        content: render_to_string(partial: 'messages/message', collection: @messages, layout: false, formats: :html) +
          (add_postloader ?
            render_to_string(partial: 'site/postloader_new', locals: { filter: 'comment', url: messages_list_url(page: @page+1, format: :json) }, formats: :html) :
            '')
      }

  end

  # разговоро с пользователем
  def talk
    @user = User.find_by_nickname(User.param_to params[:id])
    raise NotFound.new params[:id] unless @user

    @page = (params[:page] || 1).to_i
    @page_title = UsersController.profile_title('Диалог', @user)
    if params.include? :comment_id
      comment = Comment.find(params[:comment_id])
      @reply = "[quote=%s]%s[/quote]\n" % [comment.user.nickname, comment.body]
    end
    if params.include? :message_id
      message = Message.find(params[:message_id])
      raise NotFound.new params[:message_id] unless message.present? && (message.src_id == current_user.id || message.dst_id == current_user.id)
      @reply = "[quote=%s]%s[/quote]\n" % [message.user.nickname, message.body]

      # помечаем сообщение прочитанным
      message.update_attribute :read, true
    end

    ids = { comments: [], messages: [] }
    ActiveRecord::Base.connection.
      execute("select id,type
                 from (
                     select id,created_at,'comments' as type
                       from comments
                       where ((
                             commentable_id=#{@user.id}
                             and user_id=#{current_user.id}
                           ) or (
                             commentable_id=#{current_user.id}
                             and user_id=#{@user.id}
                           )
                         )
                         and commentable_type='#{User.name}'
                     union
                     select id,created_at,'messages' as type
                       from messages
                       where
                         src_type='#{User.name}'
                         and dst_type='#{User.name}'
                         and kind='#{MessageType::Private}'
                         and ((
                             src_id=#{@user.id}
                             and dst_id=#{current_user.id}
                           ) or (
                             dst_id=#{@user.id}
                             and src_id=#{current_user.id}
                           )
                         )
                   ) as t
                 order by
                   created_at desc
                 limit
                   #{@@limit * (@page-1)}, #{@@limit + 1}
              ").each {|v| ids[v[1].to_sym] << v[0].to_i }

    @messages = (Message.where(id: ids[:messages]) + Comment.where(id: ids[:comments])).sort_by(&:created_at).reverse
    @add_postloader = @messages.size > @@limit
    @messages = @messages.take(@@limit)

    @postloader_url = talk_url(id: @user.to_param, page: @page+1, format: :json)

    respond_to do |format|
      format.html {
        super_show
      }
      format.json {
        if params.include? :page
          render json: {
              content: render_to_string(partial: 'comments/comment', collection: @messages, layout: false, formats: :html) +
                (@add_postloader ?
                  render_to_string(partial: 'site/postloader', locals: { url: @postloader_url }, formats: :html) :
                  '')
            }
        else
          render json: {
              content: render_to_string(partial: 'messages/talk', formats: :html),
              title_page: @page_title,
            }
        end
      }
    end
  end

  # создание нового сообщения
  def create
    if params[:comment].include?(:feedback) && !user_signed_in?
      def self.user_signed_in?
        true
      end
      def self.current_user
        User.find(User::GuestID)
      end
      params[:comment][:body] += "\n\ne-mail: #{params[:comment][:email]}" unless params[:comment][:email].blank?
      params[:comment][:commentable_id] = 1
    end
    params[:comment][:body] += "\n\n#{params[:comment][:location]}" unless params[:comment][:location].blank?
    params[:comment][:body] += "\n#{params[:comment][:user_agent]}" unless params[:comment][:user_agent].blank?

    raise Unauthorized unless user_signed_in?
    Rails.logger.info params.to_yaml

    user = User.find(params[:comment][:commentable_id])
    unless user
      render json: {'' => 'Пользователь <b>%s</b> не найден' % params[:target][:nickname]}, status: :unprocessable_entity
      return
    end

    if user.ignored_users.include?(current_user)
      render json: {'' => User::CommentForbiddenMessage }, status: :unprocessable_entity
      return
    end

    message = Message.new({
      body: params[:comment][:body],
      dst_id: user.id,
      dst_type: user.class.name,
      src_id: current_user.id,
      src_type: current_user.class.name,
      kind: MessageType::Private
    })

    if message.save
      # отправка увекдомления получателю
      if message.kind == MessageType::Private && !message.dst.email.blank? && (message.dst.notifications & User::PRIVATE_MESSAGES_TO_EMAIL != 0)
        Sendgrid.delay(run_at: DateTime.now + 10.minutes).private_message_email(message)
      end

      render json: {
        id: message.id,
        notice: params[:comment].include?(:feedback) ? 'Отзыв отправлен' : 'Личное сообщение отправлено',
        html: render_to_string(partial: 'comments/comment', layout: false, object: message, formats: :html)
      }
    else
      render json: message.errors, status: :unprocessable_entity
    end
  end

  # пометка сообщения как прочитанного
  def read
    Message.where(id: (params[:ids] || '').split(',').map(&:to_i))
           .where(dst_id: current_user.id)
           .where(dst_type: User.name)
           .update_all(read: params[:read])

    render json: {}
  end

  # пометка сообщения как удаленного
  def destroy
    messages = Message.where(id: params[:id]).
                      where('src_id = ? or dst_id = ?', current_user.id, current_user.id).
                      all
    if messages.empty?
      render json: {'' => 'Сообщение не найдено'}, status: :unprocessable_entity
      return
    end
    message = messages.first
    message.update_attributes({ src_del: true }) if message.src_id == current_user.id
    message.update_attributes({ dst_del: true, read: true }) if message.dst_id == current_user.id

    render json: { notice: 'Сообщение удалено' }
  end

  # ключ к rss ленте уведомлений
  def self.rss_key(user)
    Digest::SHA1.hexdigest("notifications_feed_for_user_##{user.id}!")
  end

  # ключ к отписке от сообщений
  def self.unsubscribe_key(user, kind)
    Digest::SHA1.hexdigest("unsubscribe_#{kind}_messages_for_user_##{user.id}!")
  end

  def rss_key(user)
    MessagesController.rss_key(user)
  end
  def unsubscribe_key(user, kind)
    MessagesController.unsubscribe_key(user, kind)
  end

  def bounce
    User.where(email: params[:Email])
        .all
        .each do |user|

      Message.wo_antispam do
        Message.create!({
          src: BotsService.get_poster,
          dst: user,
          kind: MessageType::Notification,
          body: "Наш почтовый сервис не смог доставить письмо на вашу почту #{user.email}.\nРекомендуем сменить e-mail в настройках профиля, иначе при утере пароля вы не сможете восстановить аккаунт."
        })
      end

    end
    head 200
  end
end
