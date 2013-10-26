module CosplayHelper
  include ActionView::Helpers::TextHelper

  def geta(vector)
    return [vector] if vector.length < 2

    ret = []

    0.upto(vector.length - 1) do |n|
      rest = Marshal.load(Marshal.dump(vector))
      picked = rest.delete_at(n)

      geta(rest).each do |v|
        ret << [picked] + v
      end
    end

    ret
  end

  def extract_keywords(text)
    fix_keywords(text.gsub(/[A-Z](?:[-!A-z:\d\(\)']|\.(?! )| [a-z]{2}(?= )| [a-z]{3}(?= )| (?=[A-Z\d\(\)]).)+/))
  end

  def fix_keywords(keywords)
    keywords.map {|v|
              v.sub(/^TouhouProject$/, 'Touhou Project')
            }.
            #select {|v| !@ctags.include?(v) }.
            map {|v| v.include?('.') ? v.split('.') + [v] : v }.
            map {|v| v.include?(')') ? v.split(')') + [v] : v }.
            map {|v| v.include?('(') ? v.split('(') + [v] : v }.
            map {|v| v.split(' ').size == 2 ? [v, v.sub(' ', '')] : v }.
            flatten.
            map {|v| v == 'Dark Magician Girl' ? [v, 'Yu-Gi-Oh!', 'Mana'] : v }.
            map {|v| v == 'Black Rock Shooter' ? [v, 'Mato Kuroi', 'Yomi Takanashi'] : v }.
            map {|v| v == 'Touhou Project' ? [v, 'Anime Tenchou x Touhou Project', 'Touhou Niji Sousaku Doujin Anime: Musou Kakyou'] : v }.
            flatten.
            map {|v| v.gsub(/ [a-z]{2}$| [a-z]{3}$/, '') }.
            concat([@gallery.target]).
            concat(@gallery.target.split(':')).
            #concat(@gallery.target.split(' ')).
            map {|v| v.include?('(') && !v.include?(')') ? v.gsub(/ *\(.*/, '') : v }.
            map {|v| v.include?(')') && !v.include?('(') ? v.gsub(/ *\).*/, '') : v }.
            #select {|v| !@ctags.include?(v) }.
            map {|v|
              v.sub(/^When the Cicadas Cry$/, 'Higurashi no Naku Koro ni').
                sub(/^Rena Ryuugu$/, 'Rena Ryuuguu').
                sub(/^My-Otome$/, 'Mai-Otome').
                sub(/^Chi$/, 'Chii').
                sub(/^Esther Blanchet$/, 'Esther Blanchett').
                sub(/^The Idolmaster$/, 'iDOLM@STER Xenoglossia').
                sub(/^Alice Florence$/, 'Alicia Florence').
                sub(/^Strawberry 100%$/, 'Ichigo 100%').
                sub(/^Burning-Eyed Shana$/, 'Shana of the Burning Eyes').
                sub(/^Pastel Ink$/, 'Ink Nijihara').
                sub(/^Code Geass$/, 'Code Geass: Lelouch of the Rebellion').
                sub(/^Kyo Fujibayashi$/, 'Kyou Fujibayashi').
                sub(/^Shirley$/, 'Shirley Fenette').
                sub(/^Lelouch vi Britannia$/, 'Lelouch Lamperouge').
                sub(/^vocaloid\s+2$/i, 'Vocaloid2').
                sub(/^Sayuka Kouenji$/, 'Sayuka').
                sub(/^Kalifa$/, 'Califa').
                sub(/^Lucky Star$/, 'Lucky &#9734; Star').
                sub(/^Shoko Kirishima$/, 'Shouko Kirishima').
                sub(/^Cure Rhythm$/, 'Kanade Minamino').
                sub(/^Sweet Pretty Cure$/, 'Suite Pretty Cure').
                sub(/^Mellona$/, 'Melona').
                sub(/^Anna Kyoyama$/, 'Anna Kyouyama').
                sub(/^Hell Teacher NuuBea$/, 'Jigoku Sensei Nube').
                sub(/^Himari Noihara$/, 'Himari').
                sub(/^Ninfu$/, 'Nymph').
                #sub(/^Talho$/, 'Talho Yuuki').
                sub(/^Erika Sendo$/, 'Erika Sendou').
                sub(/^Erio Towa$/, 'Erio Touwa').
                sub(/^Meirin Hong$/, 'Hong Meiling').
                sub(/^NorikoTakaya$/, 'Noriko Takaya').
                sub(/^Kyoko Sakura$/, 'Kyouko Sakura').
                sub(/^Mahou Shoujo Madoka Magica$/, 'Mahou Shoujo Madoka★Magika').
                sub(/^Kanu untyou$/, 'Kanu Unchou').
                sub(/^Toudori$/, 'Kanako Watanabe').
                sub(/^Ferisia$/, 'Felicia').
                sub(/^Madoka Kamame$/, 'Madoka Kaname').
                sub(/^Vampire Savior$/, 'Vampire Hunter').
                sub(/Pokemon Diamond$/, 'Pokemon Diamond & Pearl').
                sub(/^Andromeda Shun$/, 'Shun "Andromeda"').
                sub(/.*of the Golden Witch$/, 'Umineko no Naku Koro ni').
                sub(/^The King of Fighters$/, 'King of Fighters').
                sub(/^Hetalia: Axis Powers$/, 'Hetalia Axis Powers').
                sub(/^Queen's (?:Blade?|Gate)(?: Rebellion)?$/, 'Queen\'s Blade: Rurou no Senshi')
            }.
            uniq.
            select {|v| v.gsub(/\W*/, '').size > 3 }.
            select {|v| ![@cosplayer.name.downcase,
                          @cosplayer.name.downcase + "'s",
                          "the",
                          "it",
                          "he",
                          "she",
                          "they",
                          "japan",
                          "japanese",
                          "animated"].include?(v.downcase) &&
                          !/^January( \d+)?$/.match(v) &&
                          !/^February( \d+)?$/.match(v) &&
                          !/^Marth( \d+)?$/.match(v) &&
                          !/^April( \d+)?$/.match(v) &&
                          !/^June( \d+)?$/.match(v) &&
                          !/^July( \d+)?$/.match(v) &&
                          !/^August( \d+)?$/.match(v) &&
                          !/^September( \d+)?$/.match(v) &&
                          !/^October( \d+)?$/.match(v) &&
                          !/^November( \d+)?$/.match(v) &&
                          !/^December( \d+)?$/.match(v)
            }
  end
end
