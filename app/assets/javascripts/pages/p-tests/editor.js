import delay from 'delay';
import csrf from 'helpers/csrf';
import autosize from 'autosize';

const IS_RAW = false || !IS_LOCAL_SHIKI_PACKAGES;
const IS_VUE = !IS_RAW || !IS_LOCAL_SHIKI_PACKAGES;

const TEST_DEMO_CONTENT = `
[anime=1]
[anime=9876543]
[character=22052]
[character=89339]
[character=118765]
[character=36828]
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
