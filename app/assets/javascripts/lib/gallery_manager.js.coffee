# динамическая загрузка картинок с борд danbooru, oreno.imouto, konachan, safebooru
@GalleryManager = ($container, $loader, image_width) ->
  $gallery = $container.parent()

  # что будем грузить
  tags = encodeURIComponent $container.data('tags')

  # какие теги отфильтровывать
  forbidden_tags = [
    'comic', 'cum', 'fellatio', 'pussy', 'penis', 'sex', 'pussy_juice', 'nude', 'nipples', 'spread_legs', 'flat_color', 'micro_bikini', 'monochrome',
    'bottomless', 'censored', 'chibi', 'meme', 'dakimakura', 'undressing', 'lowres', 'plump', 'cameltoe', 'bandaid_on_pussy', 'bandaids_on_nipples',
    'oral', 'footjob', "erect_nipples\b.*\bpanties", "breasts\b.*\btopless", 'crotch_zipper', 'bdsm', 'side-tie_panties', 'anal', 'masturbation',
    'panty_pull', 'loli', 'print_panties'
  ]

  if $gallery.data('with-hentai-images')
    forbidden_tags = null
  else
    forbidden_tags = new RegExp(_.map(forbidden_tags, (v, k) -> "\\b#{v}\\b").join("|"))

  # загрузчики картинок
  loaders = [
    new SafebooruLoader(forbidden_tags)
    #new DanbooruLoader(forbidden_tags),
    new YandeReLoader(forbidden_tags)
    new KonachanLoader(forbidden_tags)
  ]

  # кеш с картинками
  cache = []

  # по сколько картинок за раз отображать
  batch_size = 6

  # ожидается ли сейчас подгрузка картинок
  awaiting_loaders = false

  # происходит ли сейчас предзагрузка картинок
  awaiting_preload = false

  # число задеплоенных картинок
  deployed_images = 0

  # хеши полученных картинок
  hashes = {}
  hashes_count = 0

  # ширина картинки
  default_image_width = image_width

  # остались ли ещё картинки для загрузки
  check_status = ->
    if has_active_loaders() || awaiting_preload || awaiting_loaders || cache.length
      true

    else
      if loaders.length is 3 && deployed_images < 100
        loaders.push new DanbooruLoader(forbidden_tags)
        _log 'not enough images... adding DanbooruLoader'
        _.delay load

        $loader
          .hide()
          .next()
            .css(visibility: 'visible')
            .show()
        true

      else
        $loader
          .hide()
          .next()
            .css(visibility: 'hidden')
            .show()
        false

  # загрузка картинок
  load = ->
    _log "load... awaiting loaders: " + awaiting_loaders + ", awaiting_preload: " + awaiting_preload + ", cache: " + cache.length + ", active_loaders: " + _.map(_.select(loaders, (loader) ->
        not loader.is_empty()
      ), (loader) ->
        loader.name()
      ).join(",")

    if !tags || tags == 'undefined'
      # тег не задан
      $container.trigger 'danbooru:zero'
      $loader
        .hide()
        .next()
          .css visibility: 'hidden'
      return

    # все лоадеры загрузили всё, что смогли
    return unless check_status()

    awaiting_loaders = true
    if cache.length
      load_cache()

    else
      _.each loaders, (loader) ->
        loader.fetch tags, process_loader_data if !loader.is_loading() && !loader.is_empty()

  # остались ли активные загрузчики
  has_active_loaders = ->
    _.any loaders, (loader) -> !loader.is_empty()

  # обработка полученных от лоадера картинок
  process_loader_data = (loading_tags, images) ->
    # если во время загрузки поменяли теги
    return unless loading_tags == tags
    images = _.select(images, (image) ->
      (image.md5 not of hashes)
    )
    _.each images, (image) ->
      hashes[image.md5] = true
      image.preview_width = parseInt(image.preview_width)
      cache.push image
      return

    hashes_count += images.length
    load_cache() if awaiting_loaders

  # подгрузка картинок с локального кеша
  load_cache = ->
    if hashes_count > 15 && ('init_triggered' not of arguments.callee)

      # надо скрыть дефолтные картинки и послать danbooru:init
      $('.images .images-list.mal').fadeOut ->
        $container.trigger 'danbooru:init'
        return

      scroll = $(window).scrollTop()
      arguments.callee.init_triggered = true

    # вытаскиваем из кеша сколько надо
    batch = []
    i = 0

    while i < batch_size
      break unless cache.length
      image = cache.pop()
      batch.push image_html(image)
      i++

    # если набрали пачку, то больше не ждём картинок
    if batch.length > 0
      awaiting_loaders = false
      deployed_images += batch.length
      $batch = $(batch.join(""))

      # и после предзагрузки картинок выкладываем их
      awaiting_preload = true
      $($batch).imagesLoaded deploy_batch

    else if batch.length == 0 && !has_active_loaders()
      awaiting_loaders = false
      check_status()

    # 2 события для пересчёта позиции галерии, пока картинок меньше 30 и 60
    if deployed_images < 30
      $container.trigger 'danbooru:page'
    else
      $container.trigger 'danbooru:page2' if deployed_images < 60

    # когда у всех загрузчиков заканчиваются картинки, то надо скрыть крутилку
    # если ни одной картинки так и не было получено, то триггерим danbooru:zero
    $container.trigger 'danbooru:zero' if not has_active_loaders() && deployed_images is 0

  # генерация шаблона картинки
  image_html = (image) ->
    "<div class=\"image-container\"><a href=\"#{image.url}\" rel=\"danbooru\">" +
      "<img src=\"#{image.preview}\" style=\"max-width:#{default_image_width}px\" /></a></div>"

  # вставка в галерею готовых картинок
  deploy_batch = ->
    awaiting_preload = false
    $('a', @).fancybox $.galleryOptions
    $container.append @

    unless $gallery.data("danbooru")
      # активация галереи с masonry
      pars = columnWidth: default_image_width + 3
      pars['cornerStampSelector'] = '.menu-right-inner' if $(".menu-right-inner").length
      $gallery.data(danbooru: true).gallery pars

    else
      # или просто инициализация добавленных элементов
      $container.masonry 'appended', @

    if check_status()
      # показ лоадера
      $loader
        .show()
        .next()
          .css(visibility: 'hidden')
          .hide()
      $.force_appear()

  $loader.addClass 'danbooru-loader'
  $loader.on 'postloader:trigger', load

  change_tags: (new_tags) ->
    tags = encodeURIComponent(new_tags)
    cache = []
    page = 1
    awaiting_loaders = false
    awaiting_preload = false
    deployed_images = 0
    hashes = {}
    hashes_count = 0
    _.each loaders, (loader) ->
      loader.reset()

    $container
      .empty()
      .height(0)
      .removeClass('masonry')
      .data masonry: null

    $gallery
      .data(danbooru: null)
      .show()

    $loader
      .hide()
      .next()
        .css(visibility: 'visible')
          .show()
    load()
