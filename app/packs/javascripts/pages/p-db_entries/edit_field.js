pageLoad('.db_entries-edit_field', () => {
  const $description = $('.edit-page.description_ru, .edit-page.description_en');

  if ($description.exists()) {
    $('form', $description).on('submit', function() {
      const $form = $(this);

      const combineDescription = function(text, source) {
        if (source) {
          return `${text}[source]${source}[/source]`;
        }
        return `${text}`;
      };

      if ($description.hasClass('description_ru')) {
        $('[name$="description_ru]"]', $form).val(
          combineDescription(
            $('.shiki_editor-selector[data-field_name$="description_ru_text]"]', $form).view().text,
            $('[name$="description_ru_source]"]', $form).val()
          )
        );
      } else {
        $('[name$="description_en]"]', $form).val(
          combineDescription(
            $('.shiki_editor-selector[data-field_name$="description_en_text]"]', $form).view().text,
            $('[name$="description_en_source]"]', $form).val()
          )
        );
      }
    });
  }

  if ($('.edit-page.screenshots').exists()) {
    $('.c-screenshot').shikiImage();

    initSortableApp($('.screenshots-positioner'));
    initUploaderApp($('.screenshots-uploader'));
  }

  if ($('.edit-page.videos').exists()) {
    $('.videos-deleter .b-video').imageEditable();
  }

  if ($('.edit-page.imageboard_tag').exists()) {
    const $gallery = $('.b-gallery');
    const galleryHtml = $gallery.html();

    if ($gallery.data('imageboard_tag')) {
      import(/* webpackChunkName: "galleries" */ 'views/images/imageboards_gallery')
        .then(({ ImageboardsGallery }) => (
          new ImageboardsGallery($gallery)
        ));
    }

    $('#anime_imageboard_tag, #manga_imageboard_tag, #character_imageboard_tag')
      .completable()
      .on('autocomplete:success autocomplete:text', function(e, result) {
        this.value = Object.isString(result) ? result : result.value;
        $gallery.data({ imageboard_tag: this.value });
        $gallery.html(galleryHtml);

        import(/* webpackChunkName: "galleries" */ 'views/images/imageboards_gallery')
          .then(({ ImageboardsGallery }) => (
            new ImageboardsGallery($gallery)
          ));
      });
  }

  if ($('.edit-page.genre_ids').exists()) {
    const $currentGenres = $('.c-current_genres').children().last();
    const $allGenres = $('.c-all_genres').children().last();

    $currentGenres.on('click', '.remove', function() {
      const $genre = $(this).closest('.genre').remove();

      $allGenres.find(`#${$genre.attr('id')}`)
        .removeClass('included')
        .yellowFade();
    });

    $currentGenres.on('click', '.up', function() {
      const $genre = $(this).closest('.genre');
      const $prior = $genre.prev();

      $genre
        .detach()
        .insertBefore($prior)
        .yellowFade();
    });

    $currentGenres.on('click', '.down', function() {
      const $genre = $(this).closest('.genre');
      const $next = $genre.next();

      $genre
        .detach()
        .insertAfter($next)
        .yellowFade();
    });

    $allGenres.on('click', '.name', function() {
      const $genre = $(this).closest('.genre');

      if ($genre.hasClass('included')) {
        $currentGenres.find(`#${$genre.attr('id')} .remove`).click();
        return;
      }

      $genre.clone()
        .appendTo($currentGenres)
        .yellowFade();

      $genre.addClass('included');
    });

    $('form.new_version').on('submit', () => {
      const $itemDiff = $('.item_diff');

      const newIds = $currentGenres
        .children()
        .map(function() { return parseInt(this.id); })
        .toArray();
      const currentIds = $itemDiff.data('current_ids');

      const diff = { genre_ids: [currentIds, newIds] };
      $itemDiff.find('input').val(JSON.stringify(diff));
    });
  }

  if ($('.edit-page.external_links').exists()) {
    initExternalLinksApp();
  }

  const ARRAY_FIELDS = [
    'synonyms',
    'licensors',
    'coub_tags',
    'fansubbers',
    'fandubbers',
    'desynced',
    'options'
  ];
  if ($(ARRAY_FIELDS.map(v => `.edit-page.${v}`).join(',')).exists()) {
    initArrayFieldApp();
  }

  // if ($('.edit-page.licensor').exists()) {
  //   initTagsApp($('.anime_licensor, .manga_licensor'));
  // }
});

async function initExternalLinksApp() {
  const { Vue, Vuex } = await import(/* webpackChunkName: "vue" */ 'vue/instance');
  const { default: ExternalLinks } = await import('vue/components/external_links/external_links');
  const { default: storeSchema } = await import('vue/stores/collection');

  const $app = $('#vue_external_links');
  const values = $app.data('external_links').map(v => ({ ...v, key: v.id }));

  const store = new Vuex.Store(storeSchema);
  store.state.collection = values;

  new Vue({
    el: '#vue_external_links',
    store,
    render: h => h(ExternalLinks, {
      props: {
        kindOptions: $app.data('kind_options'),
        resourceType: $app.data('resource_type'),
        entryType: $app.data('entry_type'),
        entryId: $app.data('entry_id'),
        watchOnlineKinds: $app.data('watch_online_kinds')
      }
    })
  });
}

export async function initArrayFieldApp() {
  const { Vue, Vuex } = await import(/* webpackChunkName: "vue" */ 'vue/instance');
  const { default: ArrayField } = await import('vue/components/array_field');
  const { default: storeSchema } = await import('vue/stores/collection');

  const $app = $('#vue_app');
  const values = $app.data('values');

  const store = new Vuex.Store(storeSchema);
  store.state.collection = values.map((value, index) => ({
    key: index,
    value
  }));

  const app = new Vue({
    el: '#vue_app',
    store,
    render: h => h(ArrayField, {
      props: {
        resourceType: $app.data('resource_type'),
        field: $app.data('field'),
        autocompleteUrl: $app.data('autocomplete_url'),
        autocompleteType: $app.data('autocomplete_type')
      }
    })
  });

  $('form').one('submit', async e => {
    e.preventDefault();
    e.stopImmediatePropagation();

    await store.dispatch('cleanup');
    await app.$nextTick();

    e.currentTarget.submit();
  });
}

// async function initTagsApp($tags) {
//   const { Vue } = await import(/* webpackChunkName: "vue" */ 'vue/instance');
//   const { default: TagsInput } = await import('vue/components/tags_input');
// 
//   const $app = $('#vue_app');
//   $tags.hide();
// 
//   new Vue({
//     el: '#vue_app',
//     render: h => h(TagsInput, {
//       props: {
//         label: $tags.find('label').text(),
//         input: $tags.find('input')[0],
//         value: [$app.data('value')].compact(),
//         autocompleteBasic: $app.data('autocomplete_basic'),
//         autocompleteOther: [],
//         tagsLimit: 1
//       }
//     })
//   });
// }

async function initSortableApp($node) {
  if (!$node.length) { return; }

  $('form', $node).on('submit', () => {
    const $images = $('.c-screenshot:not(.deleted) img', $node);
    const ids = $images.map(function() { return $(this).data('id'); });
    $node.find('#entry_ids').val($.makeArray(ids).join(','));
  });

  const { default: Sortable } = await import('sortablejs');

  new Sortable($node.find('.cc')[0], {
    draggable: '.b-image',
    handle: '.drag-handle'
  });
}

async function initUploaderApp($node) {
  const { FileUploader } = await import('views/file_uploader');

  new FileUploader($node[0], { isResetAfterUpload: false })
    .on('upload:file:success', (_e, { response }) => (
      $(response.html)
        .appendTo($('.cc', $node))
        .shikiImage()
    ))
    .on('upload:complete', () => (
      $node.find('.thank-you').show()
    ));
}
