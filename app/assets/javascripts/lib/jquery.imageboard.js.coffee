(($) ->
  $.fn.extend imageboard: ->
    @each ->
      new ImageboardGallery(@).start()

) jQuery

# динамическая загрузка картинок с борд danbooru, oreno.imouto, konachan, safebooru
class ImageboardGallery
  # какие теги отфильтровывать
  FORBIDDEN_TAGS = [
    'comic', 'cum', 'fellatio', 'pussy', 'penis', 'sex', 'pussy_juice', 'nude', 'nipples', 'spread_legs', 'flat_color', 'micro_bikini', 'monochrome',
    'bottomless', 'censored', 'chibi', 'meme', 'dakimakura', 'undressing', 'lowres', 'plump', 'cameltoe', 'bandaid_on_pussy', 'bandaids_on_nipples',
    'oral', 'footjob', "erect_nipples\b.*\bpanties", "breasts\b.*\btopless", 'crotch_zipper', 'bdsm', 'side-tie_panties', 'anal', 'masturbation',
    'panty_pull', 'loli', 'print_panties'
  ]

  #LOADERS = [SafebooruLoader, DanbooruLoader, YandeReLoader, KonachanLoader]
  LOADERS = [SafebooruLoader, YandeReLoader, KonachanLoader]
  #LOADERS = [YandeReLoader]

  # по сколько картинок за раз отображать
  BATCH_SIZE = 12

  constructor: (root) ->
    @$root = $(root).data(shiki_object: @)
    @container_html = root.innerHTML

    @forbidden_tags = if @$root.data('with-hentai-images')
      null
    else
      new RegExp FORBIDDEN_TAGS.map((v) -> "\\b#{v}\\b").join('|')

    @_init()

  start: ->
    @$root.gallery(imageboard: true)
    @$loader = $('<p class="ajax-loading vk-like appear-marker" data-appear-top-offset="900"></p>')
      .appendTo(@$root)
      .on 'appear', =>
        @_load() unless @awaiting_preload || @awaiting_loaders
    @_load()

  refresh: ->
    @$container.packery('destroy')
    @$root.html @container_html
    @_init()
    @start()

  _init: ->
    @$container = @$root.find('.container')

    # что будем грузить
    @tags = encodeURIComponent @$root.data('tags')
    # кеш с картинками
    @cache = []
    # ожидается ли сейчас подгрузка картинок
    @awaiting_loaders = false
    # происходит ли сейчас предзагрузка картинок
    @awaiting_preload = false
    # число задеплоенных картинок
    @deployed_images = 0
    # хеши полученных картинок
    @hashes = {}
    @hashes_count = 0
    # загрузчики картинок
    @loaders = LOADERS.map (klass) => new klass(@forbidden_tags)

  # загрузка картинок
  _load: ->
    active_loaders = @loaders.filter((v) -> !v.is_empty()).map((v) -> v.name()).join(',')
    _log "load... awaiting loaders: #{@awaiting_loaders}, awaiting_preload: #{@awaiting_preload}, cache: #{@cache.length}, active_loaders: [#{active_loaders}]"

    # все лоадеры загрузили всё, что смогли
    return unless @_check_status()

    @awaiting_loaders = true

    if @cache.length
      @load_from_cache()
    else
      @loaders.each (loader) =>
        loader.fetch @tags, @_process_loader_data if !loader.is_loading() && !loader.is_empty()

  # обработка полученных от лоадера картинок
  _process_loader_data: (loading_tags, images) =>
    # во время загрузки могли поменять теги
    return unless loading_tags == @tags
    new_images = images.filter (image) => (image.md5 not of @hashes)

    new_images.each (image) =>
      @hashes[image.md5] = true
      #image.preview_width = parseInt(image.preview_width)
      @cache.push image

    @hashes_count += new_images.length
    @load_from_cache() if @awaiting_loaders

  # остались ли ещё картинки для загрузки
  _check_status: ->
    if @_has_active_loaders() || @awaiting_preload || @awaiting_loaders || @cache.length
      true
    else
      @$loader.remove()

  # остались ли активные загрузчики
  _has_active_loaders: ->
    @loaders.any (v) -> !v.is_empty()

  # подгрузка картинок с локального кеша
  load_from_cache: ->
    # вытаскиваем из кеша сколько надо
    batch = []
    i = 0

    while i < BATCH_SIZE
      break unless @cache.length
      image = @cache.pop()
      batch.push @_image_to_html(image)
      i++

    # если набрали пачку, то больше не ждём картинок
    if batch.length > 0
      @awaiting_loaders = false
      @deployed_images += batch.length
      $batch = $(batch.join(""))

      # и после предзагрузки картинок выкладываем их
      @awaiting_preload = true
      $batch.imagesLoaded @_deploy_batch

    else if batch.length == 0 && !@_has_active_loaders()
      @awaiting_loaders = false
      @_check_status()

  # генерация шаблона картинки
  _image_to_html: (image) ->
    "<a class='b-image' href='#{image.url}' rel='danbooru' data-tags='#{image.tags}'><img src='#{image.preview}'></a>"

  # вставка в галерею готовых картинок
  _deploy_batch: (images) =>
    @awaiting_preload = false

    images.elements.each (image) =>
      @$container.trigger 'imageboard:success', [$(image)]

    $.force_appear()
