function ImagesLoader(options) {
  // базовый урл борды
  var base_url = options.base_url;
  // запрещённые теги
  var forbidden_tags = options.forbidden_tags;
  // с какой страницы
  var page = 1;
  // по сколько картинок
  var limit = 100;
  // закончились ли в галерее картинки
  var is_empty = false;
  // происходит ли сейчас загрузка
  var is_loading = false;

  // обработка полученных от удалённой галереи данных
  function extract_images(data, tags) {
    if (data && 'posts' in data) {
      data = {json: data.posts.post};
    }
    if (data && 'author' in data) {
      data = {json: [data]};
    }
    if (_.isArray(data)) { // массив приходит с локальной загрузки
      data = {json: data};
    }
    if (!data || !data.json || !data.json.length) {
      is_empty = true;
      return [];
    }

    if (data.json.length != limit) {
      is_empty = true;
    }

    var images = _.select(data.json, function(image) {
      if (forbidden_tags) {
        return !(forbidden_tags.test(image.tags) || image.rating == 'e');
      } else {
        return true;
      }
    });

    return _.map(images, function(image) {
      return {
        preview_url: (options.preview_url_builder || preview_url_builder)(image, tags),
        preview_width: image.preview_width,
        preview_height: image.preview_height,
        url: (options.image_url_builder || image_url_builder)(image, tags),
        md5: image.md5,
        tags: image.tags
      };
    }).reverse();
  }

  // построитель урла к выдаче борды
  var remote_url_builder = function(base_url, page, limit, tags) {
    return base_url + '/post/index.json?page=' + page + '&limit=' + limit + '&tags=' + tags;
  };

  // построитель урла к картинке
  var image_url_builder = function(image, tags) {
    return camo_url(image, image.file_url, tags);
  };

  var preview_url_builder = function(image, tags) {
    return image.preview_url.indexOf('http') == 0 ? image.preview_url : base_url + image.preview_url;
  }

  return {
    // не закончились ли ещё картинки в галерее
    is_empty: function() {
      return is_empty;
    },
    // загружаются ли сейчас картинки из галереи
    is_loading: function() {
      return is_loading;
    },
    // получение из галереи данных
    fetch: function(tags, callback) {
      _log(options.name + ' fetch');
      var url = (options.remote_url_builder || remote_url_builder)(base_url, page, limit, tags);
      is_loading = true;

      if (options.local_load) {
        $.getJSON('/danbooru/yandere/'+Base64.encode(url)).success(function(data) {
          images = extract_images(data, tags);
          page += 1;
          is_loading = false;

          _log(options.name + ' fetched: ' + images.length + ', empty: '+is_empty);

          callback(tags, images);
        }).fail(function() {
          _log('getJSON error');
          _log(arguments);
        });

      } else {
        $['yql' + options.data_format](url, function(data) {
          images = extract_images(data, tags);
          page += 1;
          is_loading = false;

          _log(options.name + ' fetched: ' + images.length + ', empty: '+is_empty);

          callback(tags, images);
        }, function() {
          _log('yql error');
          _log(arguments);
          is_loading = false;
        });
      }
    },
    // перевод в первоначальное состояние
    reset: function() {
      is_empty = false;
      page = 1;
    },
    // имя загрузчика
    name: function() {
      return options.name;
    }
  }
};

function camo_url(image, image_url, tags) {
  var camo_base_url = "http://shikimori.org/camo";
  var extension = '.' + image_url.replace(/.*\./, '');
  var filename = (tags + '_' + image.width + 'x' + image.height + '_' +
      image.author + '_' + image.id)
    .replace(/^_/, '')
    .replace(/ /g, '__')
    .replace(/$/, extension);

  return camo_base_url + "?filename=" + filename +
    "&url=" + image_url;
}

function SafebooruLoader(forbidden_tags) {
  return new ImagesLoader({
    base_url: 'http://safebooru.org',
    data_format: 'XML',
    forbidden_tags: forbidden_tags,
    name: 'Safebooru',
    remote_url_builder: function(base_url, page, limit, tags) {
      return base_url + '/index.php?page=dapi&s=post&q=index&pid=' + (page-1) +
        '&limit=' + limit + '&tags=' + tags;
    },
    image_url_builder: function(image) {
      return image.file_url;
    }
  });
}
function DanbooruLoader(forbidden_tags) {
  var BASE_URL = 'http://danbooru.donmai.us';
  return new ImagesLoader({
    base_url: BASE_URL,
    data_format: 'JSON',
    forbidden_tags: forbidden_tags,
    name: 'Danbooru',
    image_url_builder: function(image, tags) {
      return camo_url(image, BASE_URL + image.file_url, tags);
    },
    preview_url_builder: function(image, tags) {
      return camo_url(image, BASE_URL + image.preview_url);
    }
  });
}
function YandeReLoader(forbidden_tags) {
  return new ImagesLoader({
    base_url: 'https://yande.re',
    data_format: 'JSON',
    forbidden_tags: forbidden_tags,
    name: 'YandeRe',
    local_load: true
  });
}
function KonachanLoader(forbidden_tags) {
  return new ImagesLoader({
    base_url: 'http://konachan.com',
    data_format: 'JSON',
    forbidden_tags: forbidden_tags,
    name: 'Konachan',
    preview_url_builder: function(image, tags) {
      return camo_url(image, image.preview_url, tags);
    }
  });
}
