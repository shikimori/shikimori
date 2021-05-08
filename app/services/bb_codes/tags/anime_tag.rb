class BbCodes::Tags::AnimeTag
  include Singleton
  extend DslAttribute

  dsl_attribute :klass, Anime

  FALLBACK = /(?:\ fallback=(?<fallback>.*?))?/
  NAME = /(?:\ [^\n\]\[]+)?/

  def regexp
    @regexp ||= %r{
      \[#{name}=(?<id>\d+) #{FALLBACK.source} #{NAME.source}\]
        (?! \  )
        (?<text> (?:(?!\[#{name}).)*? )
      \[/#{name}\]
      |
      \[#{name} #{FALLBACK.source} #{NAME.source}\]
        (?<id>\d+)
      \[/#{name}\]
      |
      \[#{name}=(?<id>\d+) #{FALLBACK.source} #{NAME.source}\]
      (?!\d)
    }ix
  end

  def format text
    db_entries = fetch_models text

    text.gsub regexp do |matched|
      id = $LAST_MATCH_INFO[:id].to_i
      text = $LAST_MATCH_INFO[:text]
      fallback = $LAST_MATCH_INFO[:fallback]

      model = db_entries[id]

      if model
        bbcode_to_html model.decorate, maybe_text(text, model)
      elsif fallback
        fallback
      else
        not_found_to_html matched
      end
    end
  end

private

  def bbcode_to_html model, text
    fixed_name = text.presence ?
      ERB::Util.h(text) :
      localization_span(model)

    <<~HTML.squish
      <a href='#{model_url model}' title='#{model.name}'
        class='bubbled b-link'
        data-tooltip_url='#{tooltip_url model}'
        data-attrs='#{ERB::Util.h attrs(model).to_json}'>#{fixed_name}</a>
    HTML
  end

  def not_found_to_html string
    "<span class='b-entry-404'><del>#{string}</del></span>"
  end

  def model_url model
    UrlGenerator.instance.send :"#{name}_url", model
  end

  def tooltip_url model
    UrlGenerator.instance.send :"tooltip_#{name}_url", model
  end

  def localization_span model
    if model.russian.present?
      "<span class='name-en'>#{model.name}</span>"\
        "<span class='name-ru'>#{model.russian}</span>"
    else
      model.name
    end
  end

  def maybe_text text, _model
    text # if text != model.name && text != model.russian
  end

  def attrs model
    {
      id: model.id,
      type: name,
      name: model.name,
      russian: model.russian
    }
  end

  def fetch_models text
    ids = extract_ids text
    return {} if ids.none?

    klass
      .where(id: ids)
      .index_by(&:id)
  end

  def extract_ids text
    ids = []
    text.scan(regexp) do
      ids.push $LAST_MATCH_INFO[:id].to_i if $LAST_MATCH_INFO[:id]
    end
    ids
  end

  def name
    klass.name.downcase
  end
end
