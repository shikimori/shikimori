// import delay from 'delay';
// import Turbolinks from 'turbolinks';

// $(document).on('turbolinks:load', () => {
//   const $mainSearch = $('.b-main_search');
//   const $search = $('.b-main_search input');
//   const $popup = $('.b-main_search .popup');

//   if (!$('.b-main_search').exists()) {
//     return;
//   }

//   // из урла достаём текущий тип поиска
//   let pageType = document.location.pathname.replace(/^\//, '').replace(/\/.*/, '');
//   if (!SEARCHEABLES[pageType]) {
//     pageType = $search.data('type');
//   }

//   // во всплывающей выборке типов устанавливаем текущий тип
//   $(`.type[data-type=${pageType}], .type[data-type=${pageType}]`, $popup).addClass('active');

//   $search
//     .data({
//       type: pageType,
//       autocomplete: SEARCHEABLES[pageType].autocomplete
//     })
//     .attr({
//       placeholder: I18n.t(`frontend.blocks.main_search.${pageType}`)
//     })
//     .completable($('.b-main_search .suggest-placeholder'))
//     .on('autocomplete:success', (e, entry) => {
//       const type = $search.data('type');

//       if (type === 'users') {
//         Turbolinks.visit(`/${entry.name}`, true);
//       } else {
//         Turbolinks.visit(SEARCHEABLES[type].id.replace('[id]', `aaaaaaa${entry.id}`), true);
//       }
//     })
//     .on('autocomplete:text', (e, text) => {
//       const type = $search.data('type');
//       const searchUrl = SEARCHEABLES[type].phrase.replace('[phrase]', encodeURIComponent(text));
//       document.location.href = searchUrl;
//     });

//   $search.on('parse', async () => {
//     $popup.addClass('disabled');
//     await delay();
//     $('.ac_results:visible').addClass('menu-suggest');
//   });

//   // переключение типа поиска
//   $('.b-main_search .type').on('click', ({ currentTarget }) => {
//     if ($(currentTarget).hasClass('active')) {
//       return;
//     }
//     const type = $(currentTarget).data('type');

//     $(currentTarget)
//       .addClass('active')
//       .siblings()
//       .removeClass('active');


//     $search
//       .data({ type, autocomplete: SEARCHEABLES[type].autocomplete })
//       .attr({ placeholder: I18n.t(`frontend.blocks.main_search.${type}`) })
//       .trigger('flushCache')
//       .focus();

//     // скритие типов
//     $popup.addClass('disabled');
//   });

//   // включение и отключение выбора типов
//   $popup.on('hover', () => $search.focus());
//   $search.on('keypress', () => $popup.addClass('disabled'));
//   $search.on('click', () => {
//     if ($('.ac_results:visible').length) {
//       $popup.addClass('disabled');
//     }
//     $popup.toggleClass('disabled');
//   });

//   $search.on('hover', () => {
//     if ($('.ac_results:visible').length) {
//       $popup.addClass('disabled');
//     }
//   });

//   $mainSearch.on('click', e => {
//     if ($(e.target).hasClass('b-main_search')) {
//       $search.trigger('click').trigger('focus');
//     }
//   });

//   $mainSearch.hoverDelayed(
//     () => $mainSearch.addClass('hovered'),
//     () => $mainSearch.removeClass('hovered'),
//     0,
//     250
//   );
// });

// // конфигурация автодополнений
// const SEARCHEABLES = {
//   animes: {
//     autocomplete: '/animes/autocomplete/',
//     phrase: '/animes?search=[phrase]',
//     id: '/animes/[id]',
//     regexp: /.*\/search\/(.*?)\/.*/
//   },

//   mangas: {
//     autocomplete: '/mangas/autocomplete/',
//     phrase: '/mangas?search=[phrase]',
//     id: '/mangas/[id]',
//     regexp: /.*\/search\/(.*?)\/.*/
//   },

//   ranobe: {
//     autocomplete: '/ranobe/autocomplete/',
//     phrase: '/ranobe?search=[phrase]',
//     id: '/ranobe/[id]',
//     regexp: /^\/ranobe\/(.*?)/
//   },

//   characters: {
//     autocomplete: '/characters/autocomplete/',
//     phrase: '/characters?search=[phrase]',
//     id: '/characters/[id]',
//     regexp: /^\/characters\/(.*?)/
//   },

//   seyu: {
//     autocomplete: '/people/autocomplete?kind=seyu',
//     phrase: '/seyu?search=[phrase]',
//     id: '/seyu/[id]',
//     regexp: /^\/seyu\/(.*?)/
//   },

//   producers: {
//     autocomplete: '/people/autocomplete?kind=producer',
//     phrase: '/producers?search=[phrase]',
//     id: '/person/[id]',
//     regexp: /^\/producer\/(.*?)/
//   },

//   mangakas: {
//     autocomplete: '/people/autocomplete?kind=mangaka',
//     phrase: '/mangakas?search=[phrase]',
//     id: '/person/[id]',
//     regexp: /^\/mangaka\/(.*?)/
//   },

//   people: {
//     autocomplete: '/people/autocomplete/',
//     phrase: '/people?search=[phrase]',
//     id: '/person/[id]',
//     regexp: /^\/people\/(.*?)/
//   },

//   users: {
//     autocomplete: '/users/autocomplete/',
//     phrase: '/users?search=[phrase]',
//     id: '/[id]',
//     regexp: /^\/users\/(.*?)/
//   }
// };
