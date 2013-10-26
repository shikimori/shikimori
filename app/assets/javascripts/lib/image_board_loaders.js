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
  function extract_images(data) {
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
        preview: image.preview_url.indexOf('http') == 0 ? image.preview_url : base_url + image.preview_url,
        preview_width: image.preview_width,
        preview_height: image.preview_height,
        url: (options.local_url_builder || local_url_builder)(image),
        md5: image.md5
      };
    }).reverse();
  }

  // построитель урла к выдаче борды
  var remote_url_builder = function(base_url, page, limit, tags) {
    return base_url + '/post/index.json?page=' + page + '&limit=' + limit + '&tags=' + tags;
  };

  // построитель урла к картинке
  var local_url_builder = function(image) {
    return '/d/' + image.md5 + '/' + Base64.encode(image.file_url.indexOf('http') == 0 ? image.file_url : base_url + image.file_url) + '.jpg';
  };

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
        $.getJSON('/y/'+Base64.encode(url)).success(function(data) {
          images = extract_images(data);
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
          images = extract_images(data);
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

function SafebooruLoader(forbidden_tags) {
  return new ImagesLoader({
    base_url: 'http://safebooru.org',
    data_format: 'XML',
    forbidden_tags: forbidden_tags,
    name: 'Safebooru',
    remote_url_builder: function(base_url, page, limit, tags) {
      return base_url + '/index.php?page=dapi&s=post&q=index&pid=' + (page-1) + '&limit=' + limit + '&tags=' + tags;
    },
    local_url_builder: function(image) {
      return image.file_url;
    }
  });
}
function DanbooruLoader(forbidden_tags) {
  return new ImagesLoader({
    base_url: 'http://danbooru.donmai.us',
    data_format: 'JSON',
    forbidden_tags: forbidden_tags,
    name: 'Danbooru'
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
    name: 'Konachan'
  });
}
