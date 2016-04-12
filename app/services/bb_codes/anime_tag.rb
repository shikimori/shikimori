class BbCodes::AnimeTag
  include Singleton
  extend DslAttribute

  dsl_attribute :klass, Anime

  def format text
    db_entries = fetch_entries text

    text.gsub regexp do |matched|
      entry = db_entries[$~[:id]]

      if entry
        html_for entry.decorate, $~[:name]
      else
        matched
      end
    end
  end

private

  def html_for entry, name
    <<-HTML.squish
<a href="#{entry_url entry}" title="#{entry.name}" class="bubbled b-link"
  data-tooltip_url="#{tooltip_url entry}">#{name || localized_name(entry)}</a>
    HTML
  end

  def entry_url entry
    UrlGenerator.instance.send(
      :"#{name}_url",
      entry,
      subdomain: false
    )
  end

  def tooltip_url entry
    UrlGenerator.instance.send(
      :"tooltip_#{name}_url",
      entry,
      subdomain: false
    )
  end

  def localized_name entry
    if entry.russian.present?
      <<-HTML.squish
<span class="en-name">#{entry.name}</span><span
class="ru-name" data-text="#{entry.russian}"></span>
      HTML
    else
      entry.name
    end
  end

  def fetch_entries text
    entries = {}
    text.scan(regexp) do |match|
      entries[$~[:id]] = klass.find_by id: $~[:id]
    end
    entries
  end

  def name
    klass.name.downcase
  end

  def regexp
    @regexp ||= %r{
      \[#{name}=(?<id>\d+)\] (?<name>[^\[\]].*?) \[\/#{name}\]
      |
      \[#{name}\] (?<id>\d+) \[\/#{name}\]
      |
      \[#{name}=(?<id>\d+)\] (?!=\d)
    }mix
  end
end
