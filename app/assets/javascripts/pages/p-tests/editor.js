import delay from 'delay';
import csrf from 'helpers/csrf';
import autosize from 'autosize';

const IS_RAW = false && IS_LOCAL_SHIKI_PACKAGES;
const IS_RAW_2 = false && IS_RAW && IS_LOCAL_SHIKI_PACKAGES;
const IS_VUE = !IS_RAW || !IS_LOCAL_SHIKI_PACKAGES;
let TEST_DEMO_CONTENT;

// TEST_DEMO_CONTENT = `
// zxc ||zzzzzzzzzzzzzz [anime=1] xxxxxxxx xxxxxxxxxxxxxxxxxxxx [image=1124146] xxxxxxxxxx xxxxxxxx [anime=9999999] rrrrrrrrr rrrrrrrrrrrrrr [image=1124146123] rrrrrrrrrrrrrrrrrrr rrrrrrrrrrrrrrrrrrrrrrr rrrrrrrrr rrrrrrrrrrrrrrr. ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd [comment=6180109], ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff|| zxc \`fosd fodsfosdfosdfo sdfosdfos dfosdfosdfo sdfosd fodsfodsf osdfo\` test
// ||test||
// ||test||
// \`test\`
// \`test\`
// ||test||
// ||zzzzzzzzzzzzzz [anime=9999999]zzzzzzzzzzzzzz[/anime] zzzzzzzzzzzzzz||
// 
// ||qqq [img]http://shikimori.local/system/user_images/original/1/1124146.jpg[/img] www||
// ||qqq  www||
// ||qqq [image=1124146] www||
// ||qqq  www||
// 
// `.trim();

TEST_DEMO_CONTENT = `
qqq [image=1124146] www
`.trim();

// TEST_DEMO_CONTENT = `
// [b]asdasd [anime=1] asdas[/b]
// `.trim();

// TEST_DEMO_CONTENT = `
// [b]asdasd [anime=1]Cowboy[/anime] asdas[/b]
// `.trim();

// TEST_DEMO_CONTENT = `
// [b]asdasd [anime=9999999]qwe[/anime] asdas[/b]
// [b]asdasd [anime=1]qwe[/anime] asdas[/b]
// `.trim();


// TEST_DEMO_CONTENT = `
// [div fc-2][div f-column]
// [anime=1] text after [anime=1]Anime name[/anime]
// [manga=1]
// [anime=3456789]missing anime[/anime]
// [ranobe=9115]
// 
// [image=1124146]
// [/div][div f-column]
// [entry=314310]
// [topic=314310]
// [comment=6104628]
// [message=1278854609]
// 
// [topic=99999999999]
// [topic=99999999999]missing topic[/topic]
// [comment=99999999999]
// [message=99999999999]
// [/div][/div]
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
  const rawNode2 = document.querySelector('.raw-editor-2');
  const vueNode = document.querySelector('.b-shiki_editor-v2');

  if (IS_RAW) {
    const editor = new ShikiEditor({
      element: rawNode,
      extensions: [],
      content: TEST_DEMO_CONTENT || DEMO_CONTENT,
      baseUrl: window.location.origin
    }, null, Vue);

    if (IS_RAW_2) {
      const editor2 = new ShikiEditor({
        element: rawNode2,
        extensions: [],
        content: TEST_DEMO_CONTENT || DEMO_CONTENT,
        baseUrl: window.location.origin
      }, null, Vue);
    } else {
      $(rawNode2).closest('.block').hide();
    }

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
    $(rawNode).closest('.fc-2').closest('.block').hide();
  }

  if (IS_VUE) {
    const shikiUploader = new ShikiUploader({
      locale: window.LOCALE,
      xhrEndpoint: '/api/user_images?linked_type=Comment',
      xhrHeaders: () => csrf().headers,
    });

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
          vue: Vue,
          shikiUploader,
          content: DEMO_CONTENT,
          baseUrl: window.location.origin,
        }
      })
    });
  } else {
    $(vueNode).closest('.block').hide();
  }
});

const DEMO_CONTENT = IS_LOCAL_SHIKI_PACKAGES && TEST_DEMO_CONTENT ?
  TEST_DEMO_CONTENT  :
  `# Shiki BbCodes
[div fc-2][div f-column]
[anime=1] text after [anime=1]Anime name[/anime]
[manga=1]
[anime=3456789]missing anime[/anime]
[ranobe=9115]

[image=1124146]
[/div][div f-column]
[entry=314310]
[topic=314310]
[comment=6104628]
[message=1278854609]

[topic=99999999999]
[topic=99999999999]missing topic[/topic]
[comment=99999999999]
[message=99999999999]
[/div][/div]

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

div [div=b-link_button]inline divs are not parsed by editor[/div] div

[quote]Old style quote support[/quote]
[quote=zxc]Old style quote with nickname[/quote]
[quote=c1246;1945;Silentium°]Old style quote with user[/quote]`;
