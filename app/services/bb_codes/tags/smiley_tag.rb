class BbCodes::Tags::SmileyTag
  IMAGE_PATH = '/images/smileys/'
  SMILEY_FIRST_TO_REPLACE = [':dunno:']
  SMILEY_GROUPS = [
    # rubocop:disable Layout/LineLength
    [':)', ':D', ':-D', ':lol:', ':ololo:', ':evil:', '+_+', ':cool:', ':thumbup:', ':yahoo:', ':tea2:', ':star:'],
    [':oh:', ':shy:', ':shy2:', ':hurray:', ':-P', ':roll:', ':!:', ':watching:', ':love:', ':love2:', ':bunch:', ':perveted:'],
    [':(', ':very sad:', ':depressed:', ':depressed2:', ':hopeless:', ':very sad2:', ':-(', ':cry:', ':cry6:', ':Cry2:', ':Cry3:', ':Cry4:'],
    [':-o', ':shock:', ':shock2:', ':scream:', ':dont want:', ':noooo:', ':scared:', ':shocked2:', ':shocked3:', ':shocked4:',
     ':tea shock:', ':frozen3:'],
    [':angry4:', ':revenge:', ':evil2:', ':twisted:', ':angry:', ':angry3:', ':angry5:', ':angry6:', ':cold:', ':strange4:', ':ball:', ':evil3:'],
    [':8):', ':oh2:', ':ooph:', ':wink:', ':dunno:', ':dont listen:', ':hypno:', ':advise:', ':bored:', ':disappointment:', ':hunf:'], # , ":idea:"
    [':hot:', ':hot2:', ':hot3:', ':stress:', ':strange3:', ':strange2:', ':strange1:', ':Bath2:', ':strange:', ':hope:', ':hope3:', ':diplom:'],
    [':hi:', ':bye:', ':sleep:', ':bow:', ':Warning:', ':Ban:', ':Im dead:', ':sick:', ':s1:', ':s3:', ':s2:', ':happy_cry:'],
    # rubocop:enable Layout/LineLength
    [':ill:',
     ':sad2:',
     ':bullied:', ':bdl2:',
     ':Happy Birthday:', ':flute:',
     ':cry5:',
     ':gaze:', ':hope2:',
     ':sleepy:',
     ':study:', ':study2:', ':study3:', ':gamer:',
     ':animal:',
     ':caterpillar:',
     ':cold2:', ':shocked:', ':frozen:', ':frozen2:', ':kia:', ':interested:',
     ':happy:',
     ':happy3:',
     ':water:', ':dance:', ':liar:', ':prcl:',
     ':play:',
     ':s4:', ':s:',
     ':bath:',
     ':kiss:', ':whip:', ':relax:', ':smoker:', ':smoker2:', ':bdl:', ':cool2:',
     ':V:', ':V2:', ':V3:',
     ':sarcasm:', ':angry2:', ':kya:']
  ]
  SMILEY_REGEXP_MAP = (
    SMILEY_FIRST_TO_REPLACE +
      (SMILEY_GROUPS.flatten.reverse - SMILEY_FIRST_TO_REPLACE)
  )
    .map { |smiley| Regexp.escape smiley }

  SMILEY_REGEXP = /#{SMILEY_REGEXP_MAP.join '|'}/

  HTML_TEMPLATE = <<~HTML.squish
    <img
      src="%<path>s%<smiley>s.gif"
      alt="%<smiley>s"
      title="%<smiley>s"
      class="smiley"
    />
  HTML

  SMILEY_PLACEHOLDER = '!!-SMILEY-!!'

  def preprocess text
    @cache = []

    text.gsub(SMILEY_REGEXP) do |smiley|
      @cache.push smiley
      SMILEY_PLACEHOLDER
    end
  end

  def postprocess text
    text = text.gsub(SMILEY_PLACEHOLDER) { smiley_to_html @cache.shift }

    raise BbCodes::BrokenTagError if @cache.any?

    text
  end

private

  def smiley_to_html smiley
    format HTML_TEMPLATE, path: IMAGE_PATH, smiley: smiley
  end
end
