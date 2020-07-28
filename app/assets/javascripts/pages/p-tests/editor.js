import delay from 'delay';
import csrf from 'helpers/csrf';
import autosize from 'autosize';

const IS_RAW = true || !IS_LOCAL_SHIKI_PACKAGES;
const IS_VUE = !IS_RAW || !IS_LOCAL_SHIKI_PACKAGES;

const TEST_DEMO_CONTENT = `

[spoiler=[size=20]Топ текущего месяца по мнению участников нашего клуба:tea2:[/size]]

[div=cc-7-g15]
[div=c-column b-catalog_entry][div=cover][div=image-decor][anime=877][div=image-cutter]
[poster]https://moe.shikimori.one/system/animes/original/877.jpg[/poster][/div][/anime][div=text]
4
[/div][/div][/div][/div]
[div=c-column b-catalog_entry][div=cover][div=image-decor][anime=3002][div=image-cutter]
[poster]https://kawai.shikimori.one/system/animes/original/3002.jpg[/poster][/div][/anime][div=text]
3
[/div][/div][/div][/div]
[div=c-column b-catalog_entry][div=cover][div=image-decor][anime=1827][div=image-cutter]
[poster]https://kawai.shikimori.one/system/animes/original/1827.jpg[/poster][/div][/anime][div=text]
3
[/div][/div][/div][/div]
[div=c-column b-catalog_entry][div=cover][div=image-decor][anime=477][div=image-cutter]
[poster]https://kawai.shikimori.one/system/animes/original/477.jpg[/poster][/div][/anime][div=text]
2
[/div][/div][/div][/div]
[div=c-column b-catalog_entry][div=cover][div=image-decor][anime=185][div=image-cutter]
[poster]https://dere.shikimori.one/system/animes/original/185.jpg[/poster][/div][/anime][div=text]
2
[/div][/div][/div][/div]
[div=c-column b-catalog_entry][div=cover][div=image-decor][anime=820][div=image-cutter]
[poster]https://desu.shikimori.one/system/animes/original/820.jpg[/poster][/div][/anime][div=text]
2
[/div][/div][/div][/div]
[div=c-column b-catalog_entry][div=cover][div=image-decor][anime=6211][div=image-cutter]
[poster]https://desu.shikimori.one/system/animes/original/6211.jpg[/poster][/div][/anime][div=text]
2
[/div][/div][/div][/div]
[div=c-column b-catalog_entry][div=cover][div=image-decor][anime=9756][div=image-cutter]
[poster]https://kawai.shikimori.one/system/animes/original/9756.jpg[/poster][/div][/anime][div=text]
2
[/div][/div][/div][/div]
[div=c-column b-catalog_entry][div=cover][div=image-decor][anime=30187][div=image-cutter]
[poster]https://kawai.shikimori.one/system/animes/original/30187.jpg[/poster][/div][/anime][div=text]
2
[/div][/div][/div][/div]
[div=c-column b-catalog_entry][div=cover][div=image-decor][anime=37447][div=image-cutter]
[poster]https://desu.shikimori.one/system/animes/original/37447.jpg[/poster][/div][/anime][div=text]
2
[/div][/div][/div][/div]
[div=c-column b-catalog_entry][div=cover][div=image-decor][anime=34636][div=image-cutter]
[poster]https://desu.shikimori.one/system/animes/original/34636.jpg[/poster][/div][/anime][div=text]
1
[/div][/div][/div][/div]
[div=c-column b-catalog_entry][div=cover][div=image-decor][anime=790][div=image-cutter]
[poster]https://kawai.shikimori.one/system/animes/original/790.jpg[/poster][/div][/anime][div=text]
1
[/div][/div][/div][/div]
[div=c-column b-catalog_entry][div=cover][div=image-decor][anime=6][div=image-cutter]
[poster]https://kawai.shikimori.one/system/animes/original/6.jpg[/poster][/div][/anime][div=text]
1
[/div][/div][/div][/div]
[div=c-column b-catalog_entry][div=cover][div=image-decor][anime=7785][div=image-cutter]
[poster]https://kawai.shikimori.one/system/animes/original/7785.jpg[/poster][/div][/anime][div=text]
1
[/div][/div][/div][/div]
[div=c-column b-catalog_entry][div=cover][div=image-decor][anime=918][div=image-cutter]
[poster]https://desu.shikimori.one/system/animes/original/918.jpg[/poster][/div][/anime][div=text]
1
[/div][/div][/div][/div]
[div=c-column b-catalog_entry][div=cover][div=image-decor][anime=39198][div=image-cutter]
[poster]https://kawai.shikimori.one/system/animes/original/39198.jpg[/poster][/div][/anime][div=text]
1
[/div][/div][/div][/div]
[div=c-column b-catalog_entry][div=cover][div=image-decor][anime=20583][div=image-cutter]
[poster]https://desu.shikimori.one/system/animes/original/20583.jpg[/poster][/div][/anime][div=text]
1
[/div][/div][/div][/div]
[div=c-column b-catalog_entry][div=cover][div=image-decor][anime=21843][div=image-cutter]
[poster]https://kawai.shikimori.one/system/animes/original/21843.jpg[/poster][/div][/anime][div=text]
1
[/div][/div][/div][/div]
[div=c-column b-catalog_entry][div=cover][div=image-decor][anime=269][div=image-cutter]
[poster]https://kawai.shikimori.one/system/animes/original/269.jpg[/poster][/div][/anime][div=text]
1
[/div][/div][/div][/div]
[div=c-column b-catalog_entry][div=cover][div=image-decor][anime=24833][div=image-cutter]
[poster]https://kawai.shikimori.one/system/animes/original/24833.jpg[/poster][/div][/anime][div=text]
1
[/div][/div][/div][/div]
[div=c-column b-catalog_entry][div=cover][div=image-decor][anime=603][div=image-cutter]
[poster]https://desu.shikimori.one/system/animes/original/603.jpg[/poster][/div][/anime][div=text]
1
[/div][/div][/div][/div]
[div=c-column b-catalog_entry][div=cover][div=image-decor][anime=18507][div=image-cutter]
[poster]https://kawai.shikimori.one/system/animes/original/18507.jpg[/poster][/div][/anime][div=text]
1
[/div][/div][/div][/div]
[/div]

[/spoiler]

`.trim();

// const TEST_DEMO_CONTENT = `
// [profile=27867]WhereIsMyMind[/profile]
// `.trim();

pageLoad('tests_editor', async () => {
  const $shikiEditor = $('.b-shiki_editor').shikiEditor();
  const $textarea = $shikiEditor.find('textarea');

  const { Vue } = await import(/* webpackChunkName: "vue" */ 'vue/instance');
  const { ShikiEditorApp, ShikiEditor } =
    await import(/* webpackChunkName: "shiki-editor" */
      IS_LOCAL_SHIKI_PACKAGES ?
        'packages/shiki-editor' :
        'shiki-editor'
    );
  const { default: ShikiUploader } = await import(
    IS_LOCAL_SHIKI_PACKAGES ?
      'packages/shiki-uploader' :
      'shiki-uploader'
  );

  const rawNode = document.querySelector('.raw-editor');
  const vueNode = document.querySelector('.b-shiki_editor-v2');

  if (IS_RAW) {
    const editor = new ShikiEditor({
      element: rawNode,
      extensions: [],
      content: TEST_DEMO_CONTENT,
      baseUrl: window.location.origin
    }, null, Vue);

    editor.on('update', () => {
      $textarea.val(editor.exportMarkdown())
      autosize.update($textarea[0]);
    });

    let value = editor.exportMarkdown();
    $textarea.val(value);
    autosize($textarea);

    $textarea.on('keypress keydown paste change', async () => {
      await delay();
      const newValue = $textarea.val();
      if (newValue !== value) {
        editor.setContent(newValue, false);
        value = newValue;
      }
    });
  } else {
    $(rawNode).closest('.block').hide();
  }

  if (IS_VUE) {
    new Vue({
      el: vueNode,
      components: { ShikiEditorApp },
      mounted() {
        if ($('.l-top_menu-v2').css('position') === 'sticky') {
          this.$children[0].isMenuBarOffset = true;
        }
      },
      render: h => h(ShikiEditorApp, {
        props: {
          shikiUploader: ShikiUploader,
          content: DEMO_CONTENT,
          locale: window.LOCALE,
          baseUrl: window.location.origin,
          uploadEndpoint: '/api/user_images?linked_type=Comment',
          uploadHeaders: () => csrf().headers
        }
      })
    });
  } else {
    $(vueNode).closest('.block').hide();
  }
});

const DEMO_CONTENT = IS_LOCAL_SHIKI_PACKAGES ?
  TEST_DEMO_CONTENT  :
  `# Shiki BbCodes
[anime=1] test
[anime=1]test[/anime]
[anime=16049]
[anime=3456789]
[ranobe=9115]
[image=1124146]

# Headings
[hr]
# Heading level 1: \`# Heading level 1\`
## Heading level 2: \`## Heading level 2\`
### Heading level 3: \`### Heading level 3\`
#### Heading level 4: \`#### Heading level 4\`
##### Heading level 5: \`##### Heading level 5\`

# Basic styles
[hr]
B[b]old tex[/b]t
I[i]talic tex[/i]t
U[u]nderlined tex[/u]t
S[s]triked tex[/s]t
Inline c\`ode tex\`t
Inline s||poiler tex||t    \`||spoiler content||\`
C[color=red]olored tex[/color]t   \`[color=red]...[/color]\`
s[size=18]ized tex[/size]t   \`[size=18]...[/size]\`
L[url=https://github.com/shikimori/shiki-editor]ink tex[/url]t

# Spoilers
[hr]

[spoiler=spoiler block with label]
spoiler \`content\`
[/spoiler]
[spoiler]
spoiler content
[/spoiler]

[hr]

:) :shock:

Custom DIV
\`[div=fc-2][div=f-column][/div][div=f-column][/div][/div]\`

[div=fc-2]
[div=f-column]
\`[div=f-column]\`
[/div]
[div=f-column]
\`[div=f-column]\`
[/div]
[/div]

[hr]

[right]\`[right]...[/right]\`[/right]
[center]\`[center]...[/center]\`[/center]

[hr]

\`\`\`
code block
\`\`\`
\`\`\`css
css code block
\`\`\`
- Bulet List
- def
> - \`quoted\` list
- > list \`quoted\`

> Quote
> > nope
> yes

Image
[img no-zoom 225x317]https://kawai.shikimori.one/system/animes/original/38481.jpg?1592053805[/img]     [img no-zoom width=200]https://kawai.shikimori.one/system/animes/original/38481.jpg?1592053805[/img]     [img]https://kawai.shikimori.one/system/animes/original/38481.jpg?1592053805[/img] [img]https://kawai.shikimori.one/system/users/x160/1.png?1591612283[/img]
Poster
[poster]https://www.ljmu.ac.uk/~/media/ljmu/news/starsedit.jpg[/poster]

[div=b-link_button]
\`[div=b-link_button]...[/div]\`
[/div]

div [div=b-link_button]inside line is not parsed[/div]

[quote]Old style quote support[/quote]
[quote=zxc]Old style quote with nickname[/quote]
[quote=c1246;1945;Silentium°]Old style quote with user[/quote]`;
