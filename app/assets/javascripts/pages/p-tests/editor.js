import delay from 'delay';
import csrf from 'helpers/csrf';
import autosize from 'autosize';

const IS_RAW = true && IS_LOCAL_SHIKI_PACKAGES;
const IS_RAW_2 = false && IS_LOCAL_SHIKI_PACKAGES;
const IS_VUE = !IS_RAW || !IS_LOCAL_SHIKI_PACKAGES;
let TEST_DEMO_CONTENT;

TEST_DEMO_CONTENT = `
[manga=1]
[manga=2]
[manga=3]
[manga=4]
[manga=5]
[manga=6]
[manga=7]
[manga=8]
[manga=9]
[manga=10]
[manga=11]
[manga=12]
[manga=13]
[manga=14]
[manga=15]
[manga=16]
[manga=17]
[manga=18]
[manga=19]
[manga=20]
[manga=21]
[manga=22]
[manga=23]
[manga=24]
[manga=25]
[manga=26]
[manga=27]
[manga=28]
[manga=29]
[manga=30]
[manga=31]
[manga=32]
[manga=33]
[manga=34]
[manga=35]
[manga=36]
[manga=37]
[manga=38]
[manga=39]
[manga=40]
[manga=41]
[manga=42]
[manga=43]
[manga=44]
[manga=45]
[manga=46]
[manga=47]
[manga=48]
[manga=49]
[manga=50]
[manga=51]
[manga=52]
[manga=53]
[manga=54]
[manga=55]
[manga=56]
[manga=57]
[manga=58]
[manga=59]
[manga=60]
[manga=61]
[manga=62]
[manga=63]
[manga=64]
[manga=65]
[manga=66]
[manga=67]
[manga=68]
[manga=69]
[manga=70]
[manga=71]
[manga=72]
[manga=73]
[manga=74]
[manga=75]
[manga=76]
[manga=77]
[manga=78]
[manga=79]
[manga=80]
[manga=81]
[manga=82]
[manga=83]
[manga=84]
[manga=85]
[manga=86]
[manga=87]
[manga=88]
[manga=89]
[manga=90]
[manga=91]
[manga=92]
[manga=93]
[manga=94]
[manga=95]
[manga=96]
[manga=97]
[manga=98]
[manga=99]
[manga=100]
[manga=101]
[manga=102]
[manga=103]
[manga=104]
[manga=105]
[manga=106]
[manga=107]
[manga=108]
[manga=109]
[manga=110]
[manga=111]
[manga=112]
[manga=113]
[manga=114]
[manga=115]
[manga=116]
[manga=117]
[manga=118]
[manga=119]
[manga=120]
[manga=121]
[manga=122]
[manga=123]
[manga=124]
[manga=125]
[manga=126]
[manga=127]
[manga=128]
[manga=129]
[manga=130]
[manga=131]
[manga=132]
[manga=133]
[manga=134]
[manga=135]
[manga=136]
[manga=137]
[manga=138]
[manga=139]
[manga=140]
[manga=141]
[manga=142]
[manga=143]
[manga=144]
[manga=145]
[manga=146]
[manga=147]
[manga=148]
[manga=149]
[manga=150]
[manga=151]
[manga=152]
[manga=153]
[manga=154]
[manga=155]
[manga=156]
[manga=157]
[manga=158]
[manga=159]
[manga=160]
[manga=161]
[manga=162]
[manga=163]
[manga=164]
[manga=165]
[manga=166]
[manga=167]
[manga=168]
[manga=169]
[manga=170]
[manga=171]
[manga=172]
[manga=173]
[manga=174]
[manga=175]
[manga=176]
[manga=177]
[manga=178]
[manga=179]
[manga=180]
[manga=181]
[manga=182]
[manga=183]
[manga=184]
[manga=185]
[manga=186]
[manga=187]
[manga=188]
[manga=189]
[manga=190]
[manga=191]
[manga=192]
[manga=193]
[manga=194]
[manga=195]
[manga=196]
[manga=197]
[manga=198]
[manga=199]
[manga=200]
[manga=201]
[manga=202]
[manga=203]
[manga=204]
[manga=205]
[manga=206]
[manga=207]
[manga=208]
[manga=209]
[manga=210]
[manga=211]
[manga=212]
[manga=213]
[manga=214]
[manga=215]
[manga=216]
[manga=217]
[manga=218]
[manga=219]
[manga=220]
[manga=221]
[manga=222]
[manga=223]
[manga=224]
[manga=225]
[manga=226]
[manga=227]
[manga=228]
[manga=229]
[manga=230]
[manga=231]
[manga=232]
[manga=233]
[manga=234]
[manga=235]
[manga=236]
[manga=237]
[manga=238]
[manga=239]
[manga=240]
[manga=241]
[manga=242]
[manga=243]
[manga=244]
[manga=245]
[manga=246]
[manga=247]
[manga=248]
[manga=249]
[manga=250]
[manga=251]
[manga=252]
[manga=253]
[manga=254]
[manga=255]
[manga=256]
[manga=257]
[manga=258]
[manga=259]
[manga=260]
[manga=261]
[manga=262]
[manga=263]
[manga=264]
[manga=265]
[manga=266]
[manga=267]
[manga=268]
[manga=269]
[manga=270]
[manga=271]
[manga=272]
[manga=273]
[manga=274]
[manga=275]
[manga=276]
[manga=277]
[manga=278]
[manga=279]
[manga=280]
[manga=281]
[manga=282]
[manga=283]
[manga=284]
[manga=285]
[manga=286]
[manga=287]
[manga=288]
[manga=289]
[manga=290]
[manga=291]
[manga=292]
[manga=293]
[manga=294]
[manga=295]
[manga=296]
[manga=297]
[manga=298]
[manga=299]
[manga=300]
`.trim();

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
