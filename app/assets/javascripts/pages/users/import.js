// импорт аниме/манга списка
$(function() {
  // tooltips
  $('#import, .favourite').tipsy({
    live: true,
    gravity: 'e',
    opacity: 1
  });
})
$('#import_form input').live('keypress', function(e) {
  if (e.keyCode == 13) {
    $(this).parent().parent().find('.submit').trigger('click');
  }
});
// выбор импорт или экспорт
$('#import').live('click', function() {
  $('#shade').css({opacity: 0.5}).show();

  $('#import_form > div').hide()
    .filter(':first').show();

  show_form($('#import_form'), $(this));
});
// отмена импорта
$('#cancel').live('click', function() {
  hide_form($('#import_form'), $(this));
});
// выбор экспорт или импорт
$('#import-export .control').live('click', function() {
  $('#import_form > div').hide()
    .filter('#'+$(this).data('next-step')).show();
});
// экспорт списка
$('#export_phase .control').live('click', function() {
  var $this = $(this);
  $.flash({notice: 'Начинается загрузка файла... Этот файл можно импортировать в MAL на странице http://myanimelist.net/import.php', removeTimer: 10000});
  $('#shade').trigger('click');
  _.delay(function() {
    location.href = $this.data('target');
  }, 250);
});
// выбор откуда импортировать: myanimelist.net или anime-planet.com
$('#import_phase_1 .control').live('click', function() {
  $('#import_service_name').html($(this).attr('title'));
  $('#to_final_step').data('final-step', $(this).data('final-step'));

  $('#import_phase_1').hide();
  $('#import_phase_2').show();
});
// выбор типа импорта: аниме или манга
$('#import_phase_2 .control').live('click', function() {
  $('#import_form [name=klass]').val($(this).data('klass'));
  $('#import_anime_planet_status').html($(this).data('anime-planet-status'));

  $('#import_phase_2').hide();
  $('#import_phase_3').show();
});
// выбор типа импорта: полный или частичный
$('#import_phase_3 .control').live('click', function() {
  $('#import_form [name=rewrite]').val($(this).data('rewrite'));

  $('#import_phase_3').hide();
  if ($('#to_final_step').data('final-step').match(/xml/)) {
    $('#import_xml').show();
  } else {
    $('#import_phase_4').show();
    $('#direct_mal', '#import_phase_4').hide();
  }
});
// переход на завершающую стадию импорта после указания логина в системе
$('#import_phase_4 #to_final_step').live('click', function() {
  $('#import_form [name=login]').val($('#import_form #import_login').val());

  if ($(this).data('final-step').match(/mal/)) {
    fetch_list();
  } else {
    $('#import_phase_4').hide();
    $('#'+$(this).data('final-step')).show();
  }
});
// попытка импорта напрямую, минуя yql
$('#import_phase_4 #direct_mal').live('click', function() {
  $('#import_mal #mal_login').val($('#import_form #import_login').val().toLowerCase());
  $('#import_mal .submit').trigger('click');
});

// импорт XML списка
$('#import_xml .submit').live('click', function() {
  $(this).parents('form').submit();
  _.delay(function() {
    $.flash({notice: 'Начинается импорт... Это может занять некоторое время. Пожалуйста, подождите и не обновляйте страницу.', removeTimer: 300000});
  }, 250);
});
// выбор типа импорта с anime-planet: полный или частичный
$('#import_anime_planet .control').live('click', function() {
  var $this = $(this);
  $('#import_form [name=wont_watch_strategy]').val($this.data('wont-watch-strategy'));

  $.flash({notice: 'Начинается импорт... Это может занять некоторое время. Пожалуйста, подождите и не обновляйте страницу.', removeTimer: 300000});
  _.delay(function() {
    $this.parents('form').submit();
  }, 250);
});
// загрузка списка с апи mal
function fetch_list() {
  var type = $('#import_form #klass').val();
  $.cursorMessage();

  var url = 'http://myanimelist.net/malappinfo.php?u='+$('#import_form #import_login').val().toLowerCase()+'&status=all&type='+type;
  $.yqlXML(url, function (data) {
    $.hideCursorMessage();
    try {
      if ('error' in data.myanimelist) {
        if (data.myanimelist.error == "Invalid username") {
          $.flash({notice: "Указанный логин не найден среди пользователей myanimelist."});
          return;
        }
        return;
      }
      if (!(type in data.myanimelist)) {
        $.flash({notice: 'Список получен, но он пустой. Вы не ошиблись с логином?'});
        return;
      }

      var prepared_data = JSON.stringify(_.map(data.myanimelist[type], function(v) {
        var status = 'Watching';
        if (v.my_status == '1') {
          status = 'Watching';
        } if (v.my_status == '2') {
          status = 'Completed';
        } else if (v.my_status == '3') {
          status = 'On-hold';
        } else if (v.my_status == '4') {
          status = 'Dropped';
        } else if (v.my_status == '5' || v.my_status == '6') {
          status = 'Plan to Watch';
        }
        var entry = {
          score: parseInt(v.my_score),
          status: status
        };
        if (type == 'anime') {
          entry['id'] = parseInt(v.series_animedb_id);
          entry['episodes'] = parseInt(v.my_watched_episodes);
        } else {
          entry['id'] = parseInt(v.series_mangadb_id);
          entry['volumes'] = parseInt(v.my_read_volumes);
          entry['chapters'] = parseInt(v.my_read_chapters);
        }
        return entry;
      }));

      $('#import_form #import_found').html(data.myanimelist[type].length);
      $('#import_form #data').attr('value', prepared_data);
      $('#import_phase_4').hide();
      $('#import_mal').show();
    } catch(e) {
      $.flash({alert: 'Не удалось получить список. Возможно недоступен удаленный сервис.<br />Повторите попытку позже или выберите "Попробовать иначе".'});
      $('#direct_mal', '#import_phase_4').show();
    }
  });
  return false;
}
$('#import_form .submit.import').live('click', function() {
  var $this = $(this);

  $.flash({notice: 'Начинается импорт... Это может занять некоторое время. Пожалуйста, подождите и не обновляйте страницу.', removeTimer: 300000});

  _.delay(function() {
    $this.parents('form').submit();
  }, 250);
});
$('#import_phase_2 form').live('submit', function() {
  $.cursorMessage();
});
