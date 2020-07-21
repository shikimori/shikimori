// import "shiki-editor/demo/src/stylesheets/application.sass";
// import 'shiki-editor/demo/src/stylesheets/prosemirror.sass';
import csrf from 'helpers/csrf';

pageLoad('tests_editor', async () => {
  $('.b-shiki_editor').shikiEditor();

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

  const node = document.querySelector('.b-shiki_editor-v2');

  new ShikiEditor({
    element: document.querySelector('.raw-editor'),
    extensions: [],
    content: DEMO_CONTENT,
    baseUrl: window.location.origin
  }, null, Vue);

  new Vue({
    el: node,
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
});

const DEMO_CONTENT = IS_LOCAL_SHIKI_PACKAGES ?
  `[anime=1] test
[anime=1]test[/anime]
[image=1124145]
[poster=1124145]
` :
  `# Headings
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
