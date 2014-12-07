class MessagesController < ProfilesController
  load_and_authorize_resource except: [:index, :bounce, :preview, :read_all, :delete_all, :chosen]
  skip_before_action :fetch_resource, :set_breadcrumbs, except: [:index, :read_all, :delete_all]
  before_action :authorize_acess, only: [:index, :read_all, :delete_all]

  MESSAGES_PER_PAGE = 15

  DISABLED_NOTIFICATIONS = User::MY_EPISODE_MOVIE_NOTIFICATIONS + User::MY_EPISODE_OVA_NOTIFICATIONS +
    User::NOTIFICATIONS_TO_EMAIL_SIMPLE + User::NOTIFICATIONS_TO_EMAIL_GROUP + User::NOTIFICATIONS_TO_EMAIL_NONE# +
    #User::PRIVATE_MESSAGES_TO_EMAIL

  DISABLED_CHECKED_NOTIFICATIONS = User::NOTIFICATIONS_TO_EMAIL_GROUP# + User::PRIVATE_MESSAGES_TO_EMAIL

  def index
    @page = [params[:page].to_i, 1].max
    @limit = [[params[:limit].to_i, MESSAGES_PER_PAGE].max, MESSAGES_PER_PAGE*2].min

    @collection, @add_postloader = MessagesQuery.new(@resource, @messages_type).postload @page, @limit
    @collection = @collection.map(&:decorate)

    page_title @messages_type == :news ? 'Новости сайта' : 'Уведомления сайта'
  end

  def show
    @resource = @resource.decorate
  end

  def edit
  end

  def preview
    message = Message.new(create_params).decorate
    render message
  end

  def create
    if faye.create @resource
      @resource = @resource.decorate
      render :create, notice: 'Сообщение создано'
    else
      render json: @resource.errors, status: :unprocessable_entity, notice: 'Сообщение не создано'
    end
  end

  def update
    if faye.update @resource, update_params
      @resource = @resource.decorate
      render :create, notice: 'Сообщение изменено'
    else
      render json: @resource.errors, status: :unprocessable_entity, notice: 'Сообщение не изменено'
    end
  end

  def destroy
    faye.destroy @resource
    render json: { notice: 'Сообщение удалено' }
  end

  def mark_read
    ids = params[:ids].split(',').map {|v| v.sub(/message-/, '').to_i }

    Message
      .where(id: ids, to_id: current_user.id)
      .update_all(read: true)

    head 200
  end

  def read_all
    MessagesService.new(@resource).read_messages type: @messages_type
    redirect_to index_profile_messages_url(@resource, @messages_type), notice: 'Сообщения прочитаны'
  end

  def delete_all
    MessagesService.new(@resource).delete_messages type: @messages_type
    redirect_to index_profile_messages_url(@resource, @messages_type), notice: 'Сообщения удалены'
  end

  def chosen
    @collection = Message
      .where(id: params[:ids].split(',').map(&:to_i))
      .includes(:from, :to, :linked)
      .order(:id)
      .limit(100)
      .select {|message| can? :read, message }

    render @collection.map(&:decorate)
  end

  ## rss лента сообщений
  #def feed
    #@user = User.find_by_nickname(User.param_to params[:name])
    #raise NotFound.new('user not found') if @user.nil?
    #raise NotFound.new('wrong rss key') if rss_key(@user) != params[:key]

    #raw_messages = Rails.cache.fetch "notifications_feed_#{@user.id}", expires_in: 60.minutes do
      #Message
        #.where(to_id: @user.id)
        #.where.not(kind: MessageType::Private)
        #.order('read, created_at desc')
        #.includes(:linked)
        #.limit(25)
        #.to_a
    #end

    #@messages = raw_messages.map do |message|
      #linked = message.linked && message.linked.respond_to?(:linked) && message.linked.linked ? message.linked.linked : nil
      #{
        #entry: message,
        #guid: message.guid,
        #image_url: linked && linked.image.exists? ? 'http://shikimori.org' + linked.image.url(:preview, false) : nil,
        #link: linked ? url_for(linked) : messages_url(type: :notifications),
        #linked_name: linked ? linked.name : nil,
        #pubDate: Time.at(message.created_at.to_i).to_s(:rfc822),
        #title: linked ? linked.name : 'Сайт'
      #}
    #end
    #response.headers['Content-Type'] = 'application/rss+xml; charset=utf-8'
    #render 'messages/feed', formats: :rss
  #end

  ## отписка от емайлов о сообщениях
  #def unsubscribe
    #@user = User.find_by_nickname(User.param_to params[:name])
    #raise Forbidden if @user.nil?
    #raise Forbidden if unsubscribe_key(@user, params[:kind]) != params[:key]

    #if @user.notifications & User::PRIVATE_MESSAGES_TO_EMAIL != 0
      #@user.update_attribute(:notifications, @user.notifications - User::PRIVATE_MESSAGES_TO_EMAIL)
    #end
  #end

  ## отображение сообщения
  #def show
    #@message = Message.find(params[:id])
    #raise NotFound.new('access denied') unless @message.from_id == current_user.id || @message.to_id == current_user.id

    #respond_to do |format|
      #format.html { render partial: 'comments/comment', layout: false, locals: { comment: @message }, formats: :html }
      #format.json { render json: { user: @message.user.nickname, body: @message.body } }
    #end
  #end

  ## список сообщений
  #def list
    #@page = (params[:page] || 1).to_i
    #@messages = MessagesQuery.new(current_user, params[:messages_type]).fetch @page, MESSAGES_PER_PAGE
    #add_postloader = @messages.size > MESSAGES_PER_PAGE
    #@messages = @messages.take(MESSAGES_PER_PAGE)

    #render json: {
        #content: render_to_string(partial: 'messages/message', collection: @messages, layout: false, formats: :html) +
          #(add_postloader ?
            #render_to_string(partial: 'blocks/postloader', locals: { filter: 'comment', url: messages_list_url(page: @page+1, format: :json) }, formats: :html) :
            #'')
      #}

  #end

  ## разговоро с пользователем
  #def talk
    #@user = UserProfileDecorator.new User.find_by(nickname: User.param_to(params[:id]))
    #raise NotFound.new params[:id] unless @user.object

    #@page = (params[:page] || 1).to_i
    #@page_title = UsersController.profile_title('Диалог', @user)
    #if params.include? :comment_id
      #comment = Comment.find(params[:comment_id])
      #@reply = "[quote=%s]%s[/quote]\n" % [comment.user.nickname, comment.body]
    #end
    #if params.include? :message_id
      #message = Message.find(params[:message_id])
      #raise NotFound.new params[:message_id] unless message.present? && (message.from_id == current_user.id || message.to_id == current_user.id)
      #@reply = "[quote=%s]%s[/quote]\n" % [message.user.nickname, message.body]

      ## помечаем сообщение прочитанным
      #message.update_attribute :read, true
    #end

    ##ids = { comments: [], messages: [] }
    ##ActiveRecord::Base.connection.
      ##execute("
##select
  ##id,type
##from (
  ##select
    ##id,created_at,'comments' as type
  ##from comments
  ##where
    ##((commentable_id=#{@user.id} and user_id=#{current_user.id}) or (commentable_id=#{current_user.id} and user_id=#{@user.id}))
    ##and commentable_type='#{User.name}'

  ##union all

  ##select
    ##id,created_at,'messages' as type
  ##from messages
  ##where
    ##kind='#{MessageType::Private}' and ((from_id=#{@user.id} and to_id=#{current_user.id}) or (to_id=#{@user.id} and from_id=#{current_user.id}))

##) as t
##order by
  ##created_at desc
##limit
  ###{MESSAGES_PER_PAGE * (@page-1)}, #{MESSAGES_PER_PAGE + 1}
              ##").each {|v| ids[v['type'].to_sym] << v['id'].to_i }

    ##@messages = (Message.where(id: ids[:messages]) + Comment.where(id: ids[:comments])).sort_by(&:created_at).reverse
    #@messages = Message
      #.where(kind: MessageType::Private)
      #.where("(from_id=#{@user.id} and to_id=#{current_user.id}) or (to_id=#{@user.id} and from_id=#{current_user.id})")
      #.order(created_at: :desc)
      #.offset(MESSAGES_PER_PAGE * (@page-1))
      #.limit(MESSAGES_PER_PAGE + 1)
      #.to_a

    #@add_postloader = @messages.size > MESSAGES_PER_PAGE
    #@messages = @messages.take(MESSAGES_PER_PAGE)

    #@postloader_url = talk_url(id: @user.to_param, page: @page+1, format: :json)

    #respond_to do |format|
      #format.html {
        #super_show
      #}
      #format.json {
        #if params.include? :page
          #render json: {
              #content: render_to_string(partial: 'comments/comment', collection: @messages, layout: false, formats: :html) +
                #(@add_postloader ?
                  #render_to_string(partial: 'blocks/postloader', locals: { url: @postloader_url }, formats: :html) :
                  #'')
            #}
        #else
          #render json: {
              #content: render_to_string(partial: 'messages/talk', formats: :html),
              #title_page: @page_title,
            #}
        #end
      #}
    #end
  #end

  ## создание нового сообщения
  #def create
    #if params[:comment].include?(:feedback) && !user_signed_in?
      #def self.user_signed_in?
        #true
      #end
      #def self.current_user
        #User.find(User::GuestID)
      #end
      #params[:comment][:commentable_id] = 1
    #end

    #raise Unauthorized unless user_signed_in?
    ##Rails.logger.info params.to_yaml

    #user = User.find(params[:comment][:commentable_id])
    #unless user
      #render json: {'' => 'Пользователь <b>%s</b> не найден' % params[:target][:nickname]}, status: :unprocessable_entity
      #return
    #end

    #if user.admin?
      #params[:comment][:body] = params[:comment][:body].strip
      #params[:comment][:body] += " [right][size=11][color=gray][spoiler=info]"
      #params[:comment][:body] += "e-mail: #{params[:comment][:email]}\n" unless params[:comment][:email].blank?
      #params[:comment][:body] += "[url=#{params[:comment][:location]}]#{params[:comment][:location]}[/url]\n" unless params[:comment][:location].blank?
      #params[:comment][:body] += "#{params[:comment][:user_agent] || request.env['HTTP_USER_AGENT']}\n"
      #params[:comment][:body] += '[/spoiler][/color][/size][/right]'
    #end

    #if user.ignored_users.include?(current_user)
      #render json: {'' => I18n.t('activerecord.errors.models.messages.ignored') }, status: :unprocessable_entity
      #return
    #end

    #message = Message.new(
      #from_id: current_user.id,
      #to_id: user.id,
      #kind: MessageType::Private,
      #body: params[:comment][:body]
    #)

    #if message.save
      ## отправка увекдомления получателю
      #if message.kind == MessageType::Private && !message.to.email.blank? && (message.to.notifications & User::PRIVATE_MESSAGES_TO_EMAIL != 0)
        #Sendgrid.delay_for(10.minutes).private_message_email(message)
      #end

      #render json: {
        #id: message.id,
        #notice: params[:comment].include?(:feedback) ? 'Отзыв отправлен' : 'Личное сообщение отправлено',
        #html: render_to_string(partial: 'comments/comment', layout: false, object: message, formats: :html)
      #}
    #else
      #render json: message.errors, status: :unprocessable_entity
    #end
  #end

  ## пометка сообщения как прочитанного
  #def read
    #Message
      #.where(id: (params[:ids] || '').split(',').map(&:to_i))
      #.where(to_id: current_user.id)
      #.update_all(read: params[:read])

    #render json: {}
  #end

  ## пометка сообщения как удаленного
  #def destroy
    #messages = Message
      #.where(id: params[:id])
      #.where('from_id = ? or to_id = ?', current_user.id, current_user.id)
      #.to_a
    #if messages.empty?
      #render json: ['Сообщение не найдено'], status: :unprocessable_entity
      #return
    #end
    #message = messages.first
    #message.update_attributes(src_del: true) if message.from_id == current_user.id
    #message.update_attributes(dst_del: true, read: true) if message.to_id == current_user.id

    #render json: { notice: 'Сообщение удалено' }
  #end

  ## ключ к rss ленте уведомлений
  #def self.rss_key(user)
    #Digest::SHA1.hexdigest("notifications_feed_for_user_##{user.id}!")
  #end

  ## ключ к отписке от сообщений
  #def self.unsubscribe_key(user, kind)
    #Digest::SHA1.hexdigest("unsubscribe_#{kind}_messages_for_user_##{user.id}!")
  #end

  #def rss_key(user)
    #MessagesController.rss_key(user)
  #end
  #def unsubscribe_key(user, kind)
    #MessagesController.unsubscribe_key(user, kind)
  #end

  def bounce
    User.where(email: params[:Email]).each(&:notify_bounced_email)
    head 200
  end

  # типы сообщений
  #def message_types
     #[
      #{ id: 'inbox', name: 'Входящее' },
      #{ id: 'news', name: 'Новости' },
      #{ id: 'notifications', name: 'Уведомления' },
      #{ id: 'sent', name: 'Отправленное' }
    #]
  #end

  ## число прочитанных сообщений
  #def unread_counts
    #@unread ||= {
      #'inbox' => current_user.unread_messages,
      #'news' => current_user.unread_news,
      #'notifications' => current_user.unread_notifications,
      #'sent' => 0
    #}
  #end


private
  def faye
    FayeService.new current_user, faye_token
  end

  def create_params
    params.require(:message).permit(:body, :from_id, :to_id, :kind)
  end

  def update_params
    params.require(:message).permit(:body)
  end

  def authorize_acess
    authorize! :access_messages, @resource
    @messages_type = params[:messages_type].to_sym
  end
end
