// динамическая загрузка картинок с борд danbooru, oreno.imouto, konachan, safebooru
function GalleryManager($container, $loader, image_width) {
  var $gallery = $container.parent();
  // что будем грузить
  var tags = encodeURIComponent($container.data('tags'));
  // какие теги отфильтровывать
  var forbidden_tags = [
    'comic', 'cum', 'fellatio', 'pussy', 'penis', 'sex', 'pussy_juice', 'nude', 'nipples', 'spread_legs', 'flat_color', 'micro_bikini', 'monochrome',
    'bottomless', 'censored', 'chibi', 'meme', 'dakimakura', 'undressing', 'lowres', 'plump', 'cameltoe', 'bandaid_on_pussy', 'bandaids_on_nipples',
    'oral', 'footjob', 'erect_nipples\b.*\bpanties', 'breasts\b.*\btopless', 'crotch_zipper', 'bdsm', 'side-tie_panties', 'anal', 'masturbation',
    'panty_pull', 'loli', 'print_panties'
  ];
  if ($.cookie('HentaiImages')) {
    forbidden_tags = null;
  } else {
    forbidden_tags = new RegExp(_.map(forbidden_tags, function(v,k) { return '\\b' + v + '\\b'; }).join('|'));
  }
  // загрузчики картинок
  var loaders = [
    new SafebooruLoader(forbidden_tags),
    //new DanbooruLoader(forbidden_tags),
    new YandeReLoader(forbidden_tags),
    new KonachanLoader(forbidden_tags)
  ];
  // кеш с картинками
  var cache = [];
  // по сколько картинок за раз отображать
  var batch_size = 6;
  // ожидается ли сейчас подгрузка картинок
  var awaiting_loaders = false;
  // происходит ли сейчас предзагрузка картинок
  var awaiting_preload = false;
  // число задеплоенных картинок
  var deployed_images = 0;
  // хеши полученных картинок
  var hashes = {};
  var hashes_count = 0;
  // ширина картинки
  var default_image_width = image_width;

  // остались ли ещё картинки для загрузки
  var check_status = function() {
    if (has_active_loaders() || awaiting_preload || awaiting_loaders || cache.length) {
      return true;
    } else {
      if (loaders.length == 3 && deployed_images < 100) {
        loaders.push(new DanbooruLoader(forbidden_tags));
        _log('not enough images... adding DanbooruLoader');
        _.delay(load);
      $loader.hide().next()
             .css('visibility', 'visible').show();
        return true;
      }
      $loader.hide().next()
             .css('visibility', 'hidden').show();
      return false;
    }
  };

  // загрузка картинок
  var load = function() {
    _log('load... awaiting loaders: ' + awaiting_loaders +
         ', awaiting_preload: ' + awaiting_preload +
         ', cache: ' + cache.length +
         ', active_loaders: ' + _.map(_.select(loaders, function(loader) { return !loader.is_empty(); }), function(loader) { return loader.name(); }).join(',')
        );
    if (!tags || tags === '' || tags == 'undefined') {
      // тег не задан
      $container.trigger('danbooru:zero');
      $loader.hide()
             .next()
             .css('visibility', 'hidden');
      return;
    }
    if (!check_status()) {
      // все лоадеры загрузили всё, что смогли
      return;
    }

    awaiting_loaders = true;

    if (cache.length) {
      load_cache();
    } else {
      _.each(loaders, function(loader) {
        if (!loader.is_loading() && !loader.is_empty()) {
          loader.fetch(tags, process_loader_data);
        }
      });
    }
  };
  // остались ли активные загрузчики
  var has_active_loaders = function() {
    return _.any(loaders, function(loader) { return !loader.is_empty(); });
  };

  // обработка полученных от лоадера картинок
  var process_loader_data = function(loading_tags, images) {
    if (loading_tags != tags) {
      // если во время загрузки поменяли теги
      return;
    }
    images = _.select(images, function(image) {
      return !(image.md5 in hashes);
    });
    _.each(images, function(image) {
      hashes[image.md5] = true;
      cache.push(image);
    });
    hashes_count += images.length;
    if (awaiting_loaders) {
      load_cache();
    }
  };

  // подгрузка картинок с локального кеша
  var load_cache = function() {
    if (hashes_count > 15 && !('init_triggered' in arguments.callee)) {
      // надо скрыть дефолтные картинки и послать danbooru:init
      $('.images .images-list.mal').fadeOut(function() {
        $container.trigger('danbooru:init');
      });
      var scroll = $(window).scrollTop();
      arguments.callee.init_triggered = true;
    }

    // вытаскиваем из кеша сколько надо
    var batch = [];
    for (var i = 0; i < batch_size; i++) {
      if (!cache.length) {
        break;
      }
      var image = cache.pop();
      batch.push(image_html(image));
    }
    // если набрали пачку, то больше не ждём картинок
    if (batch.length > 0) {
      awaiting_loaders = false;
      deployed_images += batch.length;

      var $batch = $(batch.join(''));
      // и после предзагрузки картинок выкладываем их
      awaiting_preload = true;
      $($batch).imagesLoaded(deploy_batch);
    } else if (batch.length == 0 && !has_active_loaders()) {
      awaiting_loaders = false;
      check_status();
    }

    // 2 события для пересчёта позиции галерии, пока картинок меньше 30 и 60
    if (deployed_images < 30) {
      $container.trigger('danbooru:page');
    } else if (deployed_images < 60) {
      $container.trigger('danbooru:page2');
    }

    // когда у всех загрузчиков заканчиваются картинки, то надо скрыть крутилку
    if (!has_active_loaders() && deployed_images == 0) {
      // если ни одной картинки так и не было получено, то триггерим danbooru:zero
      $container.trigger('danbooru:zero');
    }
  };

  // генерация шаблона картинки
  var image_html = function(image) {
    return '<div class="image-container"><a href="' + image.url + '" rel="danbooru"><img src="' + image.preview + '" width="' + (image.preview_width > default_image_width ? default_image_width : image.preview_width) + '" /></a></div>';
  };

  // вставка в галерею готовых картинок
  var deploy_batch = function() {
    awaiting_preload = false;
    $('a', this).fancybox($.galleryOptions);
    $container.append(this);

    if (!$gallery.data('danbooru')) {
      // активация галереи с masonry
      var pars = {
        columnWidth: default_image_width+3,
      };
      if ($('.menu-right-inner').length) {
        pars['cornerStampSelector'] = '.menu-right-inner';
      }
      $gallery.data('danbooru', true).gallery(pars);
    } else {
      // или просто инициализация добавленных элементов
      $container.masonry('appended', this);
    }

    if (check_status()) {
      // показ лоадера
      $loader.show()
            .next()
              .css('visibility', 'hidden')
              .hide();
    } else {
      return;
    }

    $.force_appear();
  };

  $loader.addClass('danbooru-loader');
  $loader.on('postloader:trigger', load);

  return {
    change_tags: function(new_tags) {
      tags = encodeURIComponent(new_tags);

      cache = [];
      page = 1;
      awaiting_loaders = false;
      awaiting_preload = false;
      deployed_images = 0;
      hashes = {};
      hashes_count = 0;

      _.each(loaders, function(loader) {
        loader.reset();
      });
      $container.empty()
                .height(0)
                .removeClass('masonry')
                .data('masonry', null);
      $gallery.data('danbooru', null)
              .show();
      $loader.hide()
             .next()
             .css('visibility' ,'visible')
             .show();
      load();
    }
  }
}
