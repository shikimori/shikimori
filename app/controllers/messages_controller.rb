class MessagesController < ProfilesController
  load_and_authorize_resource except: [:index, :bounce, :feed, :preview, :read_all, :delete_all, :chosen, :unsubscribe]

  skip_before_action :fetch_resource, :set_breadcrumbs, except: [:index, :read_all, :delete_all]
  skip_before_action :verify_authenticity_token, only: [:bounce]

  before_action :authorize_acess, only: [:index, :read_all, :delete_all]
  before_action :append_info, only: [:create]

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

    page_title localized_page_title
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
      render :create, notice: i18n_t('message.created')
    else
      render json: @resource.errors.full_messages,
        status: :unprocessable_entity,
        notice: i18n_t('message.not_created')
    end
  end

  def update
    if faye.update @resource, update_params
      @resource = @resource.decorate
      render :create, notice: i18n_t('message.updated')
    else
      render json: @resource.errors.full_messages,
        status: :unprocessable_entity,
        notice: i18n_t('message.not_updated')
    end
  end

  def destroy
    faye.destroy @resource
    render json: { notice: i18n_t('message.removed') }
  end

  def mark_read
    ids = (params[:ids] || '').split(',').map {|v| v.sub(/message-/, '').to_i }

    Retryable.retryable tries: 2, on: [PG::TRDeadlockDetected], sleep: 1 do
      Message
        .where(id: ids, to_id: current_user.id)
        .update_all(read: params[:unread] ? false : true)
    end

    head 200
  end

  def read_all
    MessagesService.new(current_user).read_messages type: @messages_type
    redirect_to index_profile_messages_url(current_user, @messages_type),
      notice: i18n_t('messages.read')
  end

  def delete_all
    MessagesService.new(current_user).delete_messages type: @messages_type
    redirect_to index_profile_messages_url(current_user, @messages_type),
      notice: i18n_t('messages.removed')
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

  # отписка от емайлов о сообщениях
  def unsubscribe
    @user = User.find_by_nickname(User.param_to params[:name])
    raise CanCan::AccessDenied, 'no user' if @user.nil?
    raise CanCan::AccessDenied, 'bad key' if self.class.unsubscribe_key(@user, params[:kind]) != params[:key]

    if @user.notifications & User::PRIVATE_MESSAGES_TO_EMAIL != 0
      @user.update notifications: @user.notifications - User::PRIVATE_MESSAGES_TO_EMAIL
    end
  end

  # rss лента уведомлений
  def feed
    @user = User.find_by_nickname(User.param_to params[:name])
    raise NotFound.new('user not found') if @user.nil?
    raise NotFound.new('wrong rss key') if self.class.rss_key(@user) != params[:key]

    raw_messages = Rails.cache.fetch "notifications_feed_#{@user.id}", expires_in: 60.minutes do
      Message
        .where(to_id: @user.id)
        .where.not(kind: MessageType::Private)
        .order(:read, created_at: :desc)
        .includes(:linked)
        .limit(25)
        .to_a
    end

    @messages = raw_messages.map do |message|
      linked = message.linked && message.linked.respond_to?(:linked) && message.linked.linked ? message.linked.linked : nil
      {
        entry: message.decorate,
        guid: message.guid,
        image_url: linked && linked.image.exists? ? 'http://shikimori.org' + linked.image.url(:preview, false) : nil,
        link: linked ? url_for(linked) : messages_url(type: :notifications),
        linked_name: linked ? linked.name : nil,
        pubDate: Time.at(message.created_at.to_i).to_s(:rfc822),
        title: linked ? linked.name : i18n_i('Site')
      }
    end
    response.headers['Content-Type'] = 'application/rss+xml; charset=utf-8'
    render 'messages/feed', formats: :rss
  end

  # ключ к rss ленте уведомлений
  def self.rss_key user
    Digest::SHA1.hexdigest("notifications_feed_for_user_##{user.id}!")
  end

  # ключ к отписке от сообщений
  def self.unsubscribe_key user, kind
    Digest::SHA1.hexdigest("unsubscribe_#{kind}_messages_for_user_##{user.id}!")
  end

  def bounce
    emails = JSON.parse(params[:mandrill_events]).map { |event| event['msg']['email'] }
    NamedLogger.bounce.info emails
    User.where(email: emails).each(&:notify_bounced_email)
    head 200
  end

private

  def localized_page_title
    if @messages_type == :news
      i18n_t '.site_news'
    elsif @messages_type == :private
      i18n_t '.private_messages'
    else
      i18n_t '.site_notifications'
    end
  end

  def faye
    FayeService.new current_user || User.find(User::GuestID), faye_token
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

  def append_info
    return unless @resource.to.admin?

    @resource.body.strip!
    @resource.body += " [right][size=11][color=gray][spoiler=info][quote]"
    @resource.body += "#{params[:message][:user_agent] || request.env['HTTP_USER_AGENT']}\n"
    @resource.body += "[url=#{params[:message][:location]}]#{params[:message][:location]}[/url]\n" if params[:message][:location].present?
    @resource.body += "#{params[:message][:feedback_address]}\n" if params[:message][:feedback_address].present?
    @resource.body += '[/quote][/spoiler][/color][/size][/right]'
  end
end
