import delay from 'delay';
import csrf from 'helpers/csrf';
import autosize from 'autosize';
import axios from 'helpers/axios';

const IS_RAW = false && IS_LOCAL_SHIKI_PACKAGES;
const IS_RAW_2 = false && IS_RAW && IS_LOCAL_SHIKI_PACKAGES;
const IS_VUE = !IS_RAW || !IS_LOCAL_SHIKI_PACKAGES;
let TEST_DEMO_CONTENT;

TEST_DEMO_CONTENT = `
Немного Сакуры (малая часть):
[spoiler=спойлер] [image=1171572][image=1171573][image=1171574][image=1171575][image=1171576][image=1171577][image=1171578]
[image=1171579][image=1171580][image=1171581][image=1171582][image=1171583][image=1171600][b]([spoiler=спойлер]кстати, этот момент был в популярном ныне посте в твиттере о том, как пьеротт нагнетают ситуацию с Сакурой и что на самом деле с ней "все не так плохо", жаль только, что они все правильно передали, просто создавший тот пост - не читал мангу. В нем говорилось, якобы Сакура ничего про родителей Наруто не говорила, ну да, ну да[/spoiler])[/b]
[image=1171593] [image=1171594] ([spoiler=спойлер]спойлер, и в конце манге это не изменится[/spoiler]
)  [image=1171597][image=1171596][image=1171598]([spoiler=спойлер]когда даже враг проявляет к тебе сочувствие. Сакуре же плевать на Карин было, ей два раза сказали ее полечить и только тогда она пошла это делать[/spoiler]) [image=1171599] [image=1171612][image=1171613] [image=1171610] [spoiler=спойлер]друзья и семья: ок, мы просто пыль у тебя под ногами. В особенности Ино, об которую Сакура регулярно ноги вытирала, хотя она всегда приходила ей на помощь, и в детстве и после.[/spoiler][image=1171628][spoiler=спойлер] не говоря про лицемерие в этом моменте, она отправляет на экзамене его в кусты, зная, что вокруг полно врагов и ловушек. В итоге его там вырубили. [/spoiler]  [image=1171632][image=1171633][image=1171634] [spoiler=спойлер]Когда ты истерично орешь на ребенка и ударяешь перед его лицом с такой силой, что рушишь дом. [/spoiler][image=1171638][image=1171640][image=1171641][image=1171646][/spoiler]

Коротко о великом-медике на войне:
[spoiler=спойлер]Глаз Какаши вылечил Наруто.
Шикамару спасла Цунаде (Кстати, в отличие от Харуно, у нее не было чакры Наруто)
Наруто на этот свет, вернул нам Обито (+Минато)
Обычных рядовых массово тоже спасла Цунаде. 
[image=1171584][image=1171585][image=1171586][image=1171587][image=1171588][image=1171589]
Ее звездные моменты, это сплошная показуха. Да, она пыталась, но итог таков, от нее больше вреда чем пользы.[/spoiler]

Момент из фильма, который считается каноном, поскольку Киши был сценаристом:
[spoiler=спойлер][image=1171643][image=1171644][/spoiler]
 

[replies=6233966]
`.trim()

TEST_DEMO_CONTENT = `
[spoiler=Спойлер]1\n2\n3[/spoiler]
`.trim()

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
  const { ShikiRequest } = await import(
    IS_LOCAL_SHIKI_PACKAGES ?
      'packages/shiki-utils' :
      'shiki-utils'
  );

  const shikiRequest = new ShikiRequest(window.location.origin, axios);

  const rawNode = document.querySelector('.raw-editor');
  const rawNode2 = document.querySelector('.raw-editor-2');
  const vueNode = document.querySelector('.b-shiki_editor-v2');

  if (IS_RAW) {
    const editor = new ShikiEditor({
      element: rawNode,
      extensions: [],
      content: TEST_DEMO_CONTENT || DEMO_CONTENT,
      shikiRequest
    }, null, Vue);

    if (IS_RAW_2) {
      const editor2 = new ShikiEditor({
        element: rawNode2,
        extensions: [],
        content: TEST_DEMO_CONTENT || DEMO_CONTENT,
        shikiRequest
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
      render: createElement => createElement(ShikiEditorApp, {
        props: {
          vue: Vue,
          shikiUploader,
          shikiRequest,
          content: DEMO_CONTENT
        },
        on: {
          preview(node) {
            $(node).process();
          }
        }
      })
    });
  } else {
    $(vueNode).closest('.block').hide();
  }
});

const DEMO_CONTENT = IS_LOCAL_SHIKI_PACKAGES && TEST_DEMO_CONTENT ?
  TEST_DEMO_CONTENT  : `

# Заголовки
[hr]
# Заголовок уровень 1
\`\`\`
# Заголовок уровень 1
\`\`\`

## Заголовок уровень 2
\`\`\`
## Заголовок уровень 2
\`\`\`

### Заголовок уровень 3
\`\`\`
### Заголовок уровень 3
\`\`\`

#### Спец заголовок 1
\`\`\`
#### Спец заголовок 1
\`\`\`

##### Спец заголовок 2
\`\`\`
##### Спец заголовок 2
\`\`\`

# Черта после заголовка
[hr]
# Заголовок уровень 1
[hr]
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam elit lorem, eleifend auctor posuere eget, placerat quis augue. Nunc vitae dui nec lectus eleifend elementum. Duis iaculis quam quis mi ullamcorper, eget consequat felis finibus. Phasellus scelerisque lacus egestas, fermentum purus sit amet, mattis neque. Fusce non lorem malesuada, feugiat urna id, molestie diam. Vestibulum a turpis quis nulla pharetra posuere eu ac elit. Sed vitae felis venenatis, tempor magna at, efficitur ipsum.
\`\`\`
# Заголовок уровень 1
[hr]
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam elit lorem, eleifend auctor posuere eget, placerat quis augue. Nunc vitae dui nec lectus eleifend elementum. Duis iaculis quam quis mi ullamcorper, eget consequat felis finibus. Phasellus scelerisque lacus egestas, fermentum purus sit amet, mattis neque. Fusce non lorem malesuada, feugiat urna id, molestie diam. Vestibulum a turpis quis nulla pharetra posuere eu ac elit. Sed vitae felis venenatis, tempor magna at, efficitur ipsum.
\`\`\`

## Заголовок уровень 2
[hr]
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam elit lorem, eleifend auctor posuere eget, placerat quis augue. Nunc vitae dui nec lectus eleifend elementum. Duis iaculis quam quis mi ullamcorper, eget consequat felis finibus. Phasellus scelerisque lacus egestas, fermentum purus sit amet, mattis neque. Fusce non lorem malesuada, feugiat urna id, molestie diam. Vestibulum a turpis quis nulla pharetra posuere eu ac elit. Sed vitae felis venenatis, tempor magna at, efficitur ipsum.
\`\`\`
## Заголовок уровень 2
[hr]
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam elit lorem, eleifend auctor posuere eget, placerat quis augue. Nunc vitae dui nec lectus eleifend elementum. Duis iaculis quam quis mi ullamcorper, eget consequat felis finibus. Phasellus scelerisque lacus egestas, fermentum purus sit amet, mattis neque. Fusce non lorem malesuada, feugiat urna id, molestie diam. Vestibulum a turpis quis nulla pharetra posuere eu ac elit. Sed vitae felis venenatis, tempor magna at, efficitur ipsum.
\`\`\`

### Заголовок уровень 3
[hr]
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam elit lorem, eleifend auctor posuere eget, placerat quis augue. Nunc vitae dui nec lectus eleifend elementum. Duis iaculis quam quis mi ullamcorper, eget consequat felis finibus. Phasellus scelerisque lacus egestas, fermentum purus sit amet, mattis neque. Fusce non lorem malesuada, feugiat urna id, molestie diam. Vestibulum a turpis quis nulla pharetra posuere eu ac elit. Sed vitae felis venenatis, tempor magna at, efficitur ipsum.
\`\`\`
### Заголовок уровень 3
[hr]
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam elit lorem, eleifend auctor posuere eget, placerat quis augue. Nunc vitae dui nec lectus eleifend elementum. Duis iaculis quam quis mi ullamcorper, eget consequat felis finibus. Phasellus scelerisque lacus egestas, fermentum purus sit amet, mattis neque. Fusce non lorem malesuada, feugiat urna id, molestie diam. Vestibulum a turpis quis nulla pharetra posuere eu ac elit. Sed vitae felis venenatis, tempor magna at, efficitur ipsum.
\`\`\`


# Shiki BbCodes
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
- Bullet List
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
[quote=c1246;1945;Silentium°]Old style quote with user[/quote]
`.trim();
