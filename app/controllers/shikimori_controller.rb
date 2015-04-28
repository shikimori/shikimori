class ShikimoriController < ApplicationController
  before_action { noindex && nofollow unless shikimori? }
  COOKIE_AGE_OVER_18 = :confirmed_age_over_18

  def self.page_title value
    before_action do
      if @page_title.present?
        @page_title.unshift value
      else
        page_title value
      end
    end
  end

  def self.breadcrumb value, url_builder
    before_action do
      if @breadcrumbs.present?
        @breadcrumbs = Hash[@breadcrumbs.to_a.unshift([value, send(url_builder)])]
      else
        breadcrumb value, send(url_builder)
      end
    end
  end

  def fetch_resource
    @resource ||= resource_klass.find(resource_id)
    @resource = @resource.decorate
    instance_variable_set "@#{resource_klass.name.downcase}", @resource

    if @resource.respond_to? :name
      page_title @resource.name
    elsif @resource.respond_to? :title
      page_title @resource.title
    end

    raise AgeRestricted if @resource.respond_to?(:censored?) && @resource.censored? && censored_forbidden?
  end

  def censored_forbidden?
    cookies[COOKIE_AGE_OVER_18] != 'true'
  end

  def resource_redirect
    if resource_id != @resource.to_param && request.method == 'GET' && params[:action] != 'new'
      redirect_to url_for(url_params(resource_id_key => @resource.to_param))
      false
    end
  end

  def resource_id
    @resource_id ||= params[resource_id_key]
  end

  def resource_id_key
    key = "#{resource_klass.name.downcase}_id".to_sym
    params[key] ? key : :id
  end

  def resource_klass
    self.class.name.sub(/Controller$/ ,'').singularize.constantize
  end

  # заполнение хлебных крошек
  def breadcrumb title, url
    @breadcrumbs ||= {}
    @breadcrumbs[title] = url
  end

  def page_title title, replace=false
    if replace
      @page_title = []
    else
      @page_title ||= []
    end

    @page_title.push HTMLEntities.new.decode(title)
  end

  def noindex
    set_meta_tags noindex: true
  end

  def nofollow
    set_meta_tags nofollow: true
  end

  def description text
    set_meta_tags description: text
  end

  def keywords text
    set_meta_tags keywords: text
  end

  def redirect_to_back_or_to default, *args
    if request.env["HTTP_REFERER"].present? and request.env["HTTP_REFERER"] != request.env["REQUEST_URI"]
      redirect_to :back, *args
    else
      redirect_to default, *args
    end
  end

  # TODO: выпилить
  # пагинация датасорса
  # задаёт переменные класса @page, @limit, @add_postloader
  def postload_paginate page, limit
    @page = (page || 1).to_i
    @limit = limit.to_i

    ds = yield

    entries = ds.offset(@limit * (@page-1)).limit(@limit + 1).to_a
    @add_postloader = entries.size > @limit

    @add_postloader ? entries.take(limit) : entries
  end

  # TODO: выпилить
  def chronology params
    collection = params[:source]
      .where("`#{params[:date]}` >= #{Entry.sanitize params[:entry][params[:date]]}")
      .where("#{params[:entry].class.table_name}.id != #{Entry.sanitize params[:entry].id}")
      .limit(20)
      .order(params[:date])
      .to_a + [params[:entry]]

    collection += params[:source]
      .where("`#{params[:date]}` <= #{Entry.sanitize params[:entry][params[:date]]}")
      .where.not(id: collection.map(&:id))
      .limit(20)
      .order("#{params[:date]} desc")
      .to_a

    collection = collection.sort {|l,r| r[params[:date]] == l[params[:date]] ? r.id <=> l.id : r[params[:date]] <=> l[params[:date]] }
    collection = collection.reverse if params[:desc]
    gallery_index = collection.index {|v| v.id == params[:entry].id }
    reduce = Proc.new {|v| v < 0 ? 0 : v }
    collection.slice(reduce.call(gallery_index + params[:window] + 1 < collection.size ?
                                   gallery_index - params[:window] :
                                   (gallery_index - params[:window] - (gallery_index + params[:window]  + 1 - collection.size))),
                     params[:window]*2 + 1).
               group_by do |v|
                 Russian::strftime(v[params[:date]], '%B %Y')
               end
  end

  # TODO: выпилить
  def check_post_permission
    raise Forbidden, "Вы забанены (запрет комментирования) до #{current_user.read_only_at.strftime '%H:%M %d.%m.%Y'}" unless current_user.can_post?
  end
end
