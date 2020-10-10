class BbCodes::Tags::CommentTag
  include Singleton
  extend DslAttribute

  dsl_attribute :klass, Comment
  dsl_attribute :user_field, :user
  dsl_attribute :includes_scope, true
  dsl_attribute :is_bubbled, true

  def bbcode_regexp
    @bbcode_regexp ||= %r{
      \[#{name_regexp}=(?<id>\d+) (?<quote>\ quote(?:=(?<quote_user_id>\d+))?)?\]
        (?<text> (?: (?!\[#{name_regexp}).)*? )
      \[/#{name_regexp}\]
      |
      \[#{name_regexp}=(?<id>\d+)\]
    }mix
  end

  def id_regexp
    @id_regexp ||= /\[#{name_regexp}=(\d+)/
  end

  def format text # rubocop:disable MethodLength
    entries = fetch_entries text

    text.gsub(bbcode_regexp) do
      entry_id = $LAST_MATCH_INFO[:id].to_i
      entry = entries[entry_id]

      if entry
        bbcode_to_html(
          entry,
          $LAST_MATCH_INFO[:text],
          $LAST_MATCH_INFO[:quote].present?
        )
      else
        not_found_to_html(
          entry_id,
          $LAST_MATCH_INFO[:text],
          $LAST_MATCH_INFO[:quote_user_id]
        )
      end
    end
  end

private

  def bbcode_to_html entry, text, is_quoted
    user = entry&.send(self.class::USER_FIELD)

    author_name = text.presence || user.nickname || NOT_FOUND
    type = entry.class.name.downcase
    url = entry_url entry
    css_classes = css_classes entry, user, is_quoted
    quoted_html = quoted_html is_quoted, user, author_name
    mention_html = is_quoted ? '' : '<s>@</s>'

    "<a href='#{url}' class='#{css_classes}'" \
      " data-id='#{entry.id}' data-type='#{type}' data-text='#{user.nickname}'" \
      ">#{mention_html}#{quoted_html}</a>"
  end

  def not_found_to_html entry_id, text, quote_user_id
    user = User.find_by id: quote_user_id if quote_user_id.present?

    if user
      not_found_quote_to_html entry_id, text, user
    else
      not_found_mention_to_html entry_id, text
    end
  end

  def not_found_mention_to_html entry_id, text
    url = entry_id_url entry_id
    open_tag = url ? "a href='#{url}'" : 'span'
    close_tag = url ? 'a' : 'span'
    css_classes = url && self.class::IS_BUBBLED ?
      'b-mention b-entry-404 bubbled' :
      'b-mention b-entry-404'

    "<#{open_tag} class='#{css_classes}'><s>@</s>" +
      (text.present? ? "<span>#{text}</span>" : '') +
      "<del>[#{name}=#{entry_id}]</del></#{close_tag}>"
  end

  def not_found_quote_to_html entry_id, text, user
    "[user=#{user.id}]#{text}[/user]<span class='b-mention b-entry-404'>" \
      "<del>[#{name}=#{entry_id}]</del></span>"
  end

  def entry_url entry
    UrlGenerator.instance.send :"#{name}_url", entry
  end

  def entry_id_url entry_id
    UrlGenerator.instance.send :"#{name}_url", entry_id
  end

  def css_classes entry, user, is_quoted
    [
      ('bubbled' if entry && self.class::IS_BUBBLED),
      'b-mention',
      ('b-user16' if user && is_quoted && user.avatar.present?)
    ].compact.join(' ')
  end

  def quoted_html is_quoted, user, quoted_name
    if is_quoted
      quoteed_author_html user, quoted_name
    else
      "<span>#{quoted_name}</span>"
    end
  end

  def quoteed_author_html user, quoted_name
    return "<span>#{quoted_name}</span>" unless user&.avatar&.present?

    <<-HTML.squish
      <img
        src="#{ImageUrlGenerator.instance.url user, :x16}"
        srcset="#{ImageUrlGenerator.instance.url user, :x32} 2x"
        alt="#{quoted_name}"
      /><span>#{quoted_name}</span>
    HTML
  end

  def fetch_entries text
    entry_ids = text.scan(id_regexp).map { |v| v[0].to_i }
    return [] if entry_ids.none?

    scope = klass.where(id: entry_ids)

    if self.class::INCLUDES_SCOPE
      scope = scope.includes(self.class::USER_FIELD)
    end

    scope.index_by(&:id)
  end

  def name
    klass.base_class.name.downcase
  end

  def name_regexp
    name
  end
end
