class BbCodes::Tags::CommentTag
  include Singleton
  extend DslAttribute

  dsl_attribute :klass, Comment
  dsl_attribute :user_field, :user

  def bbcode_regexp
    @regexp ||= %r{
      \[#{name_regexp}=(?<id>\d+) (?<quote>\ quote)?\]
        (?<text> .*? )
      \[/#{name_regexp}\]
      |
      \[#{name_regexp}=(?<id>\d+)\]
    }mix
  end

  def id_regexp
    @id_regexp ||= /\[#{name_regexp}=(\d+)/
  end

  def format text
    entries = fetch_entries text

    text.gsub(bbcode_regexp) do
      bbcode_to_html(
        $LAST_MATCH_INFO[:id],
        $LAST_MATCH_INFO[:text],
        $LAST_MATCH_INFO[:quote].present?,
        entries
      )
    end
  end

private

  def bbcode_to_html entry_id, text, is_quoted, entries
    entry = entries[entry_id.to_i]
    user = entry&.send(self.class::USER_FIELD) if is_quoted || text.blank?

    author_name = extract_author user, text, entry_id
    css_classes = [
      'bubbled',
      ('b-user16' if is_quoted)
    ].compact.join(' ')

    "[url=#{entry_url(entry, entry_id)} #{css_classes}]" +
      author_html(is_quoted, user, author_name) +
      '[/url]'
  end

  def entry_url entry, entry_id
    UrlGenerator.instance.send :"#{name}_url", entry || entry_id
  end

  def author_html is_quoted, user, author_name
    if is_quoted
      quoteed_author_html user, author_name
    else
      "@#{author_name}"
    end
  end

  def quoteed_author_html user, author_name
    return "<span>#{author_name}</span>" unless user&.avatar&.present?

    <<-HTML.squish
      <img
        src="#{user.avatar_url 16}"
        srcset="#{user.avatar_url 32} 2x"
        alt="#{author_name}"
      /><span>#{author_name}</span>
    HTML
  end

  def extract_author user, text, entry_id
    text.presence || user&.nickname || entry_id
  end

  def fetch_entries text
    entry_ids = text.scan(id_regexp).map { |v| v[0].to_i }

    klass
      .where(id: entry_ids)
      .includes(self.class::USER_FIELD)
      .index_by(&:id)
  end

  def name
    klass.base_class.name.downcase
  end

  def name_regexp
    name
  end
end
