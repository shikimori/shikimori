/* global IS_LOCAL_SHIKI_PACKAGES */
/* eslint max-len:0 */

import delay from 'delay';
import autosize from 'autosize';
import axios from 'helpers/axios';

const IS_RAW = false && IS_LOCAL_SHIKI_PACKAGES;
const IS_RAW_2 = false && IS_RAW && IS_LOCAL_SHIKI_PACKAGES;
const IS_VUE = !IS_RAW || !IS_LOCAL_SHIKI_PACKAGES;
let TEST_DEMO_CONTENT;

if (process.env.NODE_ENV === 'development') {
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
`.trim();

  TEST_DEMO_CONTENT = `
[b]Результаты прошлых опросов:[/b]
[spoiler=[b]01[/b]][b]Результаты опроса #1 - "Любимая аниме-тян":[/b]
1 место -  [character=7373] и [Asuna Yuuki] (21 голос)
2 место - [Kurisu Makise] (19 голосов)
3 место - [Hitagi Senjougahara] (17 голосов)
4 место - [Mikasa Ackerman] (14 голосов)
5 место - [Saeko Busujima] и [Yuno Gasai] (11 голосов)
6 место - [Misaki Ayuzawa], [character=738], [Mashiro Shiina] и [Shiki Ryougi] (8 голосов)
7 место - [Aika Fuwa], [character=4158], [Rias Gremory], [Urumi Kanzaki], [C.C.]  (6 голосов)
8 место - [character=674], [character=64595], [Sophie Hatter], [Yoruichi Shihouin], [Kurousagi], [Mei Misaki], [Mikoto Misaka] (5 голосов)
9 место - [character=17364], [Morgiana], [character=723], [Rikka Takanashi], [Saber], [Sena Kashiwazaki], [Tsukiko Tsutsukakushi], [Victorique de Blois], [Arcueid Brunestud], [Asuka Langley Souryuu], [Chihaya Ayase], [Emi Yusa] и [Erza Scarlet] (4 голоса)
10 место - [Himeko Inaba], [character=272], [character=87], [Kuroyukihime], [Koko Hekmatyar], [Konata Izumi], [Lucy Heartfilia], [Masami Iwasawa], [Momiji Binboda], [Nana Osaki], [Ruri Gokou], [Taiga Aisaka], [Yuuko Ichihara] и [Yuuko Kanoe] (3 голоса)
[/spoiler]
, [spoiler=[b]02[/b]][b]
Результаты опроса #2 - "Любимый аниме-кун":[/b]
1 место - [Kazuto Kirigaya] и [Lelouch Lamperouge] (17 голосов)
2 место - [Koyomi Araragi] и [Rintarou Okabe] (14 голосов)
3 место - [Gintoki Sakata] и [Hei] (13 голосов)
4 место - [Eikichi Onizuka] (11 голосов)
5 место - [Kamina] (9 голосов)
6 место - [Hachiman Hikigaya] и [Houtarou Oreki] (8 голосов)
7 место - [Izaya Orihara], [L Lawliet] и [Shizuo Heiwajima] (7 голосов)
8 место - [Accelerator], [Edward Elric], [Howl], [Keima Katsuragi], [Kyon], [Mugen], [Natsu Dragneel], [Rin Okumura], [Shougo Makishima], [Takashi Natsume], [Takumi Usui] и [Toua Tokuchi] (6 голосов)
9 место -  [Eren Yeager], [Guts], [Izayoi Sakamaki], [Killua Zoldyck], [Kimihiro Watanuki], [Kraft Lawrence], [Tetsuya Kuroko], [character=18344], [Vash the Stampede] и [Yuzuru Otonashi] (5 голосов)
10 место - [character=31], [Light Yagami], [Sebastian Michaelis], [Sougo Okita], [Spike Spiegel] и [Toushirou Hijikata] (4 голоса)
11 место - [Akatsuki Ousawa], [Death the Kid], [character=391], [Kyouya Hibari], [character=45627], [Luffy Monkey D.], [Ryouta Sakamoto], [Taiga Kagami] и [Tomoya Okazaki] (3 голоса)
[/spoiler], [spoiler=[b]03[/b]]
[b]Результаты опроса #3 - "Лучший антагонист":[/b]
1 место - [Shougo Makishima] (15 голосов)
2 место - [Izaya Orihara] (12 голосов)
3 место - [character=96223]Beatrice Ushiromiya[/character] (9 голосов)
4 место - [Kurumi Tokisaki] (8 голосов)
5 место - [Accelerator] (7 голосов)
6 место - [Akihiko Kayaba], [character=2514] и [Sousuke Aizen] (6 голосов)
7 место - [character=53641], [King Bradley], [Makoto Shishio], [character=18210] и [Tyki Mikk] (5 голосов)
8 место - [Shinsuke Takasugi], [Kirei Kotomine], [Ulquiorra Cifer], [Byakuran], [character=19714] и [Suigintou] (4 голоса)
9 место - [Griffith], [Dio Brando], [Medusa Gorgon], [character=351], [character=12732], [Johan Liebert], [Sai], [Hao Asakura], [character=31] и [Riko Mine] (3 голоса)
[/spoiler], [spoiler=[b]04[/b]]
[b]Результаты опроса #4 - "Лучший питомец":[/b]
1 место - [character=13784]Madara[/character] (25 голосов)
2 место - [character=43187]Kuro[/character] (15 голосов)
3 место - [character=5188]Happy[/character] (13 голосов)
4 место - [character=2165]Mao[/character] и [Sadaharu] (10 голосов)
5 место - [Pikachu] (8 голосов)
6 место - [character=64595]Neko[/character] (6 голосов)
7 место - [Mokona Modoki] (5 голосов)
8 место - [character=6887]Mokona Modoki[/character], [Kyuubey] и [character=3133]Jiji[/character] (4 голоса)
9 место - [Chopper Tony Tony], [Dera Mochimazzi], [Rinon], [Cerberos] и [Saito Hiraga] (3 голоса)
[/spoiler], [spoiler=[b]05[/b]]
[b]Результаты опроса #5 - "Лишний персонаж":[/b]
1 место - [Chiho Sasaki], [Hinata Shintani] и [Nate River] (5 голосов)
2 место - [Kyouko Sasagawa] и [Haru Miura] (4 голоса)
3 место - [Suguha Kirigaya], [Ranko Saouji], [Momoe Okonogi], [Haruka Nanami] и [Yukiteru Amano] (3 голоса)
[/spoiler], [spoiler=[b]06[/b]]
[b]Результаты опроса #6 - "Лучший опенинг":[/b]
1. [Mirai Nikki] OP1
2. [Deadman Wonderland]
3. [Death Note] OP1
4. [Shingeki no Kyojin] OP1
5. [Steins;Gate]
6. [Higurashi no Naku Koro ni]
7. [Angel Beats!]
8. [Ergo Proxy]
9. [Samurai Champloo]
10. [Soul Eater] OP1
11. [Ao no Exorcist] OP1
12. [Baccano!]
13. [Bakemonogatari] OP1
14. [Cowboy Bebop]
15. [Durarara!!] OP1
16. [Elfen Lied]
17. [Guilty Crown] OP1
18. [Sayonara Zetsubou Sensei]
19. [Toradora!] OP2
[/spoiler], [spoiler=[b]07[/b]]
[b]Результаты опроса #7 - "Лучшая яндере/янгире":[/b]
1 место - [Yuno Gasai] (25 голосов)
2 место - [character=738]Lucy[/character] (14 голосов)
3 место - [Rena Ryuuguu] (11 голосов)
4 место - [Shion Sonozaki] (9 голосов)
5 место - [character=8631]Shiro[/character] (7 голосов)
6 место - [Ayase Aragaki], [Kotonoha Katsura] и [Misa Amane] (5 голосов)
7 место - [Minatsuki Takami] и [Megumi Shimizu]  (4 голоса)
8 место - [Ryouko Asakura], [Tsubasa Hanekawa], [Shouko Kirishima], [Kurumi Tokisaki] и [Miya Satsuki] (3 голоса)
[/spoiler], [spoiler=[b]08[/b]]
[b]Результаты опроса #8 - "Лучший эндинг":[/b]
1. [Free!]
2. [Ookami to Koushinryou]
3. [Kill Me Baby]
4. [Bakemonogatari]
5. [FLCL]
6. [Steins;Gate]
7. [Angel Beats!]
8. [anime=9756]Mahou Shoujo Madoka★Magica[/anime]
9. [Sayonara Zetsubou Sensei]
10. [K-On!!]
11. [Cowboy Bebop]
12. [Devil Survivor 2 The Animation]
13. [Cuticle Tantei Inaba]
14. [Gosick]
15. [Joshiraku]
16. [K-On!]
17. [Monster]
18. [Psycho-Pass]
19. [Shinsekai yori]
20. [Umineko no Naku Koro ni]
[/spoiler]
`.trim();

  TEST_DEMO_CONTENT = `
[*] [url=https://shikimori.org/clubs/315-achivki-dostizheniya/topics/227419-gar][b]ГАР[/b][/url] ([url=https://github.com/shikimori/neko-achievements/tree/master/priv/rules/gar.yml][color=#FF0000]g[/color][color=#AA5500]i[/color][color=#55AA00]t[/color][color=#00FF00]h[/color][color=#00AA55]u[/color][color=#0055AA]b[/color][/url]) | [div=b-anime_status_tag anons]ручной[/div] | [div=b-anime_status_tag news]процент[/div] |
`.trim();

  TEST_DEMO_CONTENT = `
- a [spoiler=b]
- c
- d
[/spoiler]
- test
`.trim();
}

pageLoad('tests_editor', async () => {
  const $shikiEditor = $('.b-shiki_editor');
  const $textarea = $shikiEditor.find('textarea');

  const { Vue } = await import(/* webpackChunkName: "vue" */ 'vue/instance');
  const { ShikiEditor } =
    await import(/* webpackChunkName: "shiki-editor" */
      IS_LOCAL_SHIKI_PACKAGES ?
        'packages/shiki-editor' :
        'shiki-editor'
    );
  const { ShikiRequest } = await import(
    IS_LOCAL_SHIKI_PACKAGES ?
      'packages/shiki-utils' :
      'shiki-utils'
  );

  const shikiRequest = new ShikiRequest(window.location.origin, axios);

  const rawNode = document.querySelector('.raw-editor');
  const rawNode2 = document.querySelector('.raw-editor-2');
  const vueNode = document.querySelector('.b-shiki_editor-v2 div');

  if (IS_RAW) {
    const editor = new ShikiEditor({
      element: rawNode,
      extensions: [],
      content: TEST_DEMO_CONTENT || DEMO_CONTENT,
      shikiRequest
    }, null, Vue);

    if (IS_RAW_2) {
      new ShikiEditor({
        element: rawNode2,
        extensions: [],
        content: TEST_DEMO_CONTENT || DEMO_CONTENT,
        shikiRequest
      }, null, Vue);
    } else {
      $(rawNode2).closest('.block').hide();
    }

    editor.on('update', () => {
      $textarea.val(editor.exportMarkdown());
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
    await delay(100);
    const view = $('.b-shiki_editor-v2').view();
    view.editorApp.setContent(TEST_DEMO_CONTENT || DEMO_CONTENT, false);
  } else {
    $(vueNode).closest('.block').hide();
  }
});

const DEMO_CONTENT = IS_LOCAL_SHIKI_PACKAGES && TEST_DEMO_CONTENT ?
  TEST_DEMO_CONTENT : `

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
Instead use \`[span]\` bbcode [span=b-anime_status_tag anons]as inline element[/span]
\`\`\`
Instead use \`[span]\` bbcode [span=b-anime_status_tag anons]as inline element[/span]
\`\`\`

[quote]Old style quote support[/quote]
[quote=zxc]Old style quote with nickname[/quote]
[quote=c1246;1945;Silentium°]Old style quote with user[/quote]
`.trim();
