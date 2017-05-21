class BbCodes::AnimeTag
  include Singleton
  extend DslAttribute

  dsl_attribute :klass, Anime

  FALLBACK = /(?:\ fallback=(?<fallback>.*?))?/

  def regexp
    @regexp ||= %r{
      \[#{name}=(?<id>\d+) #{FALLBACK.source} \]
        (?! [\ ] )
        (?<name>.*?)
      \[\/#{name}\]
      |
      \[#{name} #{FALLBACK.source}\]
        (?<id>\d+)
      \[\/#{name}\]
      |
      \[#{name}=(?<id>\d+) #{FALLBACK.source}\]
      (?!\d)
    }ix
  end

  def format text
    db_entries = fetch_entries text

    text.gsub regexp do |matched|
      id = $LAST_MATCH_INFO[:id].to_i
      name = $LAST_MATCH_INFO[:name]
      fallback = $LAST_MATCH_INFO[:fallback]

      entry = db_entries[id]

      if entry
        html_for entry.decorate, (name if name != entry.name)
      elsif fallback
        fallback
      else
        matched
      end
    end
  end

private

  def html_for entry, name
    <<-HTML.squish
<a href="#{entry_url entry}" title="#{entry.name}" class="bubbled b-link"
data-tooltip_url="#{tooltip_url entry}">#{name || localization_span(entry)}</a>
    HTML
  end

  def entry_url entry
    UrlGenerator.instance.send :"#{name}_url", entry, subdomain: false
  end

  def tooltip_url entry
    UrlGenerator.instance.send :"tooltip_#{name}_url", entry, subdomain: false
  end

  def localization_span entry
    if entry.russian.present?
      "<span class='name-en'>#{entry.name}</span>"\
      "<span class='name-ru' data-text='#{entry.russian}'></span>"
    else
      entry.name
    end
  end

  def fetch_entries text
    ids = []
    text.scan(regexp) do |match|
      ids.push $LAST_MATCH_INFO[:id].to_i if $LAST_MATCH_INFO[:id]
    end

    if ids.any?
      klass.where(id: ids).each_with_object({}) { |v, memo| memo[v.id] = v }
    else
      {}
    end
  end

  def name
    klass.name.downcase
  end
end
