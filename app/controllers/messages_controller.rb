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
  before_filter :authenticate_user!, only: [:index, :show, :list, :talk, :destroy, :read]

  helper_method :message_types
  helper_method :unread_counts

  # отображение страницы личных сообщений
  def index
    @user ||= UserProfileDecorator.new current_user.object

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
      Message.where(to_id: @user.id)
      .where.not(kind: MessageType::Private)
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
    response.headers['Content-Type'] = 'application/rss+xml; charset=utf-8'
    render 'messages/feed', formats: :rss
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
    @message = Message.find(params[:id])
    raise NotFound.new('access denied') unless @message.from_id == current_user.id || @message.to_id == current_user.id

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
            render_to_string(partial: 'blocks/postloader', locals: { filter: 'comment', url: messages_list_url(page: @page+1, format: :json) }, formats: :html) :
            '')
      }

  end

  # разговоро с пользователем
  def talk
    @user = UserProfileDecorator.new User.find_by(nickname: User.param_to(params[:id]))
    raise NotFound.new params[:id] unless @user.object

    @page = (params[:page] || 1).to_i
    @page_title = UsersController.profile_title('Диалог', @user)
    if params.include? :comment_id
      comment = Comment.find(params[:comment_id])
      @reply = "[quote=%s]%s[/quote]\n" % [comment.user.nickname, comment.body]
    end
    if params.include? :message_id
      message = Message.find(params[:message_id])
      raise NotFound.new params[:message_id] unless message.present? && (message.from_id == current_user.id || message.to_id == current_user.id)
      @reply = "[quote=%s]%s[/quote]\n" % [message.user.nickname, message.body]

      # помечаем сообщение прочитанным
      message.update_attribute :read, true
    end

    #ids = { comments: [], messages: [] }
    #ActiveRecord::Base.connection.
      #execute("
#select
  #id,type
#from (
  #select
    #id,created_at,'comments' as type
  #from comments
  #where
    #((commentable_id=#{@user.id} and user_id=#{current_user.id}) or (commentable_id=#{current_user.id} and user_id=#{@user.id}))
    #and commentable_type='#{User.name}'

  #union all

  #select
    #id,created_at,'messages' as type
  #from messages
  #where
    #kind='#{MessageType::Private}' and ((from_id=#{@user.id} and to_id=#{current_user.id}) or (to_id=#{@user.id} and from_id=#{current_user.id}))

#) as t
#order by
  #created_at desc
#limit
  ##{@@limit * (@page-1)}, #{@@limit + 1}
              #").each {|v| ids[v['type'].to_sym] << v['id'].to_i }

    #@messages = (Message.where(id: ids[:messages]) + Comment.where(id: ids[:comments])).sort_by(&:created_at).reverse
    @messages = Message
      .where(kind: MessageType::Private)
      .where("(from_id=#{@user.id} and to_id=#{current_user.id}) or (to_id=#{@user.id} and from_id=#{current_user.id})")
      .order(created_at: :desc)
      .offset(@@limit * (@page-1))
      .limit(@@limit + 1)
      .to_a

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
                  render_to_string(partial: 'blocks/postloader', locals: { url: @postloader_url }, formats: :html) :
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
      params[:comment][:commentable_id] = 1
    end

    raise Unauthorized unless user_signed_in?
    #Rails.logger.info params.to_yaml

    user = User.find(params[:comment][:commentable_id])
    unless user
      render json: {'' => 'Пользователь <b>%s</b> не найден' % params[:target][:nickname]}, status: :unprocessable_entity
      return
    end

    if user.admin?
      params[:comment][:body] = params[:comment][:body].strip
      params[:comment][:body] += " [right][size=11][color=gray][spoiler=info]"
      params[:comment][:body] += "e-mail: #{params[:comment][:email]}\n" unless params[:comment][:email].blank?
      params[:comment][:body] += "[url=#{params[:comment][:location]}]#{params[:comment][:location]}[/url]\n" unless params[:comment][:location].blank?
      params[:comment][:body] += "#{params[:comment][:user_agent] || request.env['HTTP_USER_AGENT']}\n"
      params[:comment][:body] += '[/spoiler][/color][/size][/right]'
    end

    if user.ignored_users.include?(current_user)
      render json: {'' => User::CommentForbiddenMessage }, status: :unprocessable_entity
      return
    end

    message = Message.new(
      from_id: current_user.id,
      to_id: user.id,
      kind: MessageType::Private,
      body: params[:comment][:body]
    )

    if message.save
      # отправка увекдомления получателю
      if message.kind == MessageType::Private && !message.to.email.blank? && (message.to.notifications & User::PRIVATE_MESSAGES_TO_EMAIL != 0)
        Sendgrid.delay_for(10.minutes).private_message_email(message)
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
    Message
      .where(id: (params[:ids] || '').split(',').map(&:to_i))
      .where(to_id: current_user.id)
      .update_all(read: params[:read])

    render json: {}
  end

  # пометка сообщения как удаленного
  def destroy
    messages = Message
      .where(id: params[:id])
      .where('from_id = ? or to_id = ?', current_user.id, current_user.id)
      .to_a
    if messages.empty?
      render json: ['Сообщение не найдено'], status: :unprocessable_entity
      return
    end
    message = messages.first
    message.update_attributes(src_del: true) if message.from_id == current_user.id
    message.update_attributes(dst_del: true, read: true) if message.to_id == current_user.id

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
    User.where(email: params[:Email]).each(&:notify_bounced_email)
    head 200
  end

  # типы сообщений
  def message_types
     [
      { id: 'inbox', name: 'Входящее' },
      { id: 'news', name: 'Новости' },
      { id: 'notifications', name: 'Уведомления' },
      { id: 'sent', name: 'Отправленное' }
    ]
  end

  # число прочитанных сообщений
  def unread_counts
    @unread ||= {
      'inbox' => current_user.unread_messages,
      'news' => current_user.unread_news,
      'notifications' => current_user.unread_notifications,
      'sent' => 0
    }
  end
end
