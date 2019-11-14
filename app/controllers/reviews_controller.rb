# frozen_string_literal: true

class ReviewsController < AnimesController # rubocop:disable ClassLength
  load_and_authorize_resource

  before_action :actualize_resource
  before_action :add_title
  before_action :add_breadcrumbs, except: [:index]
  skip_before_action :og_meta

  REVIEWS_CLUB_ID = 293
  ADDITIONAL_TEXT = %r{
    \[spoiler=Рекомендации\]
      (?<text>[\s\S]+)
    \[/spoiler\]
    \s*\Z
  }mix

  # обзоры аниме или манги
  def index
    query = Reviews::Query.new(
      @resource.object,
      current_user,
      locale_from_host,
      params[:id].to_i
    )
    @collection = query.fetch
      .map do |review|
        topic = review.maybe_topic locale_from_host
        Topics::ReviewView.new topic, true, true
      end
  end

  def new
    og page_title: i18n_t('new_review')
    @additional_text = additinal_text if ru_host? && I18n.russian?
  end

  def edit
    og page_title: i18n_t('edit_review')
  end

  def create
    @review = Review::Create.call resource_params, locale_from_host

    if @review.errors.blank?
      topic = @review.maybe_topic locale_from_host
      redirect_to(
        UrlGenerator.instance.topic_url(topic),
        notice: i18n_t('review.created')
      )
    else
      new
      render :new
    end
  end

  def update
    Review::Update.call @review, resource_params

    if @review.errors.blank?
      topic = @review.maybe_topic locale_from_host
      redirect_to(
        UrlGenerator.instance.topic_url(topic),
        notice: i18n_t('review.updated')
      )
    else
      edit
      render :edit
    end
  end

  def destroy
    @review.destroy
    render json: { notice: i18n_t('review.removed') }
  end

private

  def resource_params
    params
      .require(:review)
      .permit(
        :user_id,
        :target_type,
        :target_id,
        :text,
        :storyline,
        :characters,
        :animation,
        :music,
        :overall
      )
  end

  # тип класса лежит в параметрах
  def resource_klass
    @resource_klass ||= params[:type].constantize
  end

  def resource_id
    @resource_id ||= params[:anime_id] || params[:manga_id] ||
      params[:ranobe_id]
  end

  def add_breadcrumbs
    breadcrumb(
      i18n_i('Review', :other),
      send("#{resource_klass.name.downcase}_reviews_url", @resource)
    )

    if @review&.persisted? && params[:action] != 'show'
      breadcrumb(
        i18n_t('review_by', nickname: @review.user.nickname),
        @review.url
      )
      @back_url = @review.url
    else
      @back_url = send("#{resource_klass.name.downcase}_reviews_url", @resource)
    end
  end

  def add_title
    og page_title: i18n_i('Review', :other)
    og page_title: i18n_t('review_by', nickname: @review.user.nickname) if params[:action] == 'show'
  end

  def actualize_resource
    if @resource.is_a? Review
      @review = @resource.decorate
      @resource = @anime || @manga || @ranobe
    end
  end

  def additinal_text
    reviews_club = Club.find_by(id: REVIEWS_CLUB_ID)

    Rails.cache.fetch [reviews_club, :guideline] do
      if reviews_club.description =~ ADDITIONAL_TEXT
        text = $LAST_MATCH_INFO[:text]
        BbCodes::EntryText.call text, reviews_club
      end
    end
  end
end
