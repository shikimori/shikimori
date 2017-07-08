class Studio < ApplicationRecord
  Merged = {
    83 => 48,
    88 => 48,
    292 => 48,
    425 => 48,
    436 => 48,
    805 => 48,
    141 => 18,
    94 => 73
  }

  validates :image, attachment_content_type: { content_type: /\Aimage/ }

  # Relations
  has_and_belongs_to_many :animes
  has_attached_file :image,
    url: "/system/studios/:style/:id.:extension",
    path: ":rails_root/public/system/studios/:style/:id.:extension"

  STUDIO_NAME_FILTER = /°|^studios? | studios?$| productions?$| entertainment?$| animation?$|^animation? /i

  def self.filtered_name name
    #name.downcase.gsub(STUDIO_NAME_FILTER, '')
    name.gsub(STUDIO_NAME_FILTER, '')
  end

  def filtered_name
    Studio.filtered_name name
  end

  # создающая ли это аниме студия или просто продюссер
  def real?
    REAL_STUDIOS.include?(self.class.filtered_name(self.name).downcase)
  end

  # возвращет настоящую струдию, если это была склеенная студия
  def real
    Merged.keys.include?(self.id) ? self.class.find(Merged[self.id]) : self
  end

  # возвращет все id, связанные с текущим
  def self.related(id)
    Merged.map { |k,v| k == id ? v : (v == id ? k : nil) }.compact << id
  end

  # возвращает все аниме студии с учетом склеенных студий
  def all_animes
    self.animes unless Merged.values.include?(self.id)
    ids = []
    ApplicationRecord.connection
        .execute('SELECT * FROM animes_studios where studio_id in (%s)' % (Merged.select {|k,v| v == self.id }.map {|k,v| k } + [self.id]).join(',')).each do |v|
      ids << v[0]
    end
    Anime.where(id: ids)
  end

  def to_param
    "%d-%s" % [id, name.gsub(/[^\w]+/, '-').gsub(/^-|-$/, '')]
  end

  REAL_STUDIOS = [
    "artland",
    "actas",
    "studio hibari",
    "studio rikka",
    "ufotable",
    "hal film maker",
    "synergysp",
    "production i.g",
    "brains base",
    "daume",
    "comix wave",
    "white fox",
    "ob planning",
    "manglobe",
    "arms",
    "studio gallop",
    "satelight",
    "aic",
    #"warner bros. animation",
    "a.c.g.t.",
    "appp",
    "feel.",
    'silver link',
    "tyo animations",
    "madhouse",
    "madhouse studios",

    # my custom
    "daiwon media",
    "lerche",

    # с википедии
    "a-1 pictures inc.",
    "a. film",
    "a.c.g.t",
    "aardman animations",
    "act3animation",
    "actas inc.",
    "akom",
    "anima studios",
    "animafilm",
    "animal logic",
    "animation collective",
    "animax entertainment",
    "anime international company inc.",
    "anzovin studio",
    "arms corporation",
    "artland, inc.",
    "asahi production",
    "asterisk animation",
    "atomic cartoons",
    "bardel entertainment",
    "bee train production inc.",
    "bee train",
    "bent image lab",
    "big idea productions",
    "bird studios",
    "blue sky studios",
    "blue-zoo",
    "bolexbrothers",
    "bones",
    "bones",
    "brain's base",
    "brb international",
    "brown bag films",
    "cammot",
    "cartoon network studios",
    "cartoon pizza/jumbo pictures",
    "cartoon saloon",
    "clockwork zoo animation",
    "collingwood o'hare entertainment",
    "cookie jar group",
    "cosgrove hall films",
    "cosmic toast studios",
    "crest animation studios",
    "cuckoo's nest studio",
    "daume",
    "david production",
    "dax international",
    "def2shoot",
    "diomedea",
    "disneytoon studios",
    "dogakobo",
    "dong woo animation",
    "dr movie",
    "dreamworks animation",
    "eight bit",
    "eiken",
    "eiken",
    "fatkat",
    "feel",
    "fifth avenue",
    "film roman, inc.",
    "filmfair",
    "fine arts films",
    "folimage",
    "fox animation studios",
    "frederator studios",
    "future thought productions",
    "gainax",
    "gainax",
    "gallop",
    "global mechanic",
    "gohands",
    "gonzo",
    "gonzo",
    "group tac",
    "group tac",
    "guru studios",
    "h5",
    "hal film maker",
    "haoliners animation league",
    "highlander productions",
    "hong ying animation",
    "hoods entertainment",
    "ilion animation studios",
    "illumination entertainment",
    "imagi animation studios",
    "imagin",
    "j.c. staff",
    "j.c.staff",
    "jetix animation concepts",
    "jibjab",
    "kandor graphics",
    "klasky csupo",
    "koko enterprises",
    "kyoto animation",
    "kyoto animation",
    "laika",
    "les' copaque production",
    "linterna magica studio",
    "littlenobody",
    "lucasfilm animation",
    "mac guff",
    "magic bus",
    "manglobe",
    "mappa",
    "march entertainment",
    "marwah films & video studios",
    "melnitsa animation studio",
    "metro-goldwyn-mayer animation",
    "mike young productions",
    "mirari films",
    "mook animation",
    "mushi production",
    "national film board of canada",
    "naz",
    "nelvana",
    "nickelodeon animation studios",
    "nippon animation",
    "nippon animation",
    "nomad",
    "olm",
    "ordet",
    "p.a. works",
    "p.a. works",
    "pacific data images",
    "palm studio",
    "pannóniafilm",
    "pentamedia graphics",
    "pierrot plus",
    "pierrot",
    "pixar",
    "plus one animation",
    "post amazers",
    "powerhouse animation studios, inc.",
    "production i.g",
    "production i.g",
    "production reed",
    "radicial axis",
    "rainmaker digital effects",
    "renegade animation",
    "rhythm and hues studios",
    "rough draft studios",
    "rubicon group holding",
    "saerom",
    "satelight",
    "se-ma-for",
    "shaft",
    "shaft",
    "shin-ei animation",
    "six point harness",
    "skycron",
    "smallfilms",
    "sony pictures animation",
    "soup2nuts",
    "soyuzmultfilm",
    "sparx*",
    "spectrum animation",
    "spy pictures",
    "spümcø",
    "start anima",
    "starz animation",
    "stretch films",
    "studio 3hz",
    "studio 4°c",
    "studio 4°c",
    "studio b",
    "studio comet",
    "studio comet",
    "studio deen",
    "studio deen",
    "studio fantasia",
    "studio gallop",
    "studio ghibli",
    "studio ghibli",
    "studio gokumi",
    "studio hibari",
    "studio nue",
    "studio pierrot",
    "sumo dojo",
    "sunrise",
    "sunrise",
    "sunwoo entertainment",
    "synergysp",
    "tatsunoko production",
    "tatsunoko productions",
    "teletoon canada",
    "tezuka production",
    "the people's republic of animation",
    "tin house",
    "titmouse",
    "tms entertainment",
    "tms",
    "tnk",
    "toei animation",
    "toei animation",
    "toon city",
    "toonz",
    "triangle staff",
    "trigger",
    "ufotable",
    "universal animation studios",
    "w!ldbrain",
    "walsh family media",
    "walt disney animation studios",
    "walt disney television animation",
    "wang film productions",
    "white fox",
    "williams street studios",
    "wit studio",
    "xebec",
    "xebec",
    "xilam",
    "xyzoo animation",
    "zagreb school of animated films",
    "zexcs",
    "šaf",
  ].map {|v| v.gsub(STUDIO_NAME_FILTER, '') }
end
