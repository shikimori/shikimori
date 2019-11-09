pageLoad('articles_new', 'articles_edit', 'articles_create', 'articles_update', () => {
  $('.b-shiki_editor.unprocessed').shikiEditor();

  if ($('#article_tags').length) {
    initTagsApp();
  }
});

async function initTagsApp() {
  const { Vue } = await import(/* webpackChunkName: "vue" */ 'vue/instance');
  const { default: TagsInput } = await import('vue/components/tags_input');

  const $app = $('#vue_tags_input');
  const $tags = $('.b-input.article_tags');
  $tags.hide();

  new Vue({
    el: '#vue_tags_input',
    render: h => h(TagsInput, {
      props: {
        label: $tags.find('label').text(),
        hint: $tags.find('.hint').html(),
        input: $tags.find('input')[0],
        value: $app.data('value'),
        autocompleteBasic: $app.data('autocomplete_basic'),
        autocompleteOther: [],
        tagsLimit: 3,
        isDowncase: true
      }
    })
  });
}
