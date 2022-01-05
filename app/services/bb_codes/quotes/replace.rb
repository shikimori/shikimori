class BbCodes::Quotes::Replace
  method_object %i[text! from_reply! to_reply!]

  QUOTE_REPLACEMENT_TEMPLATES = [{
    from_regexp_template: (
      <<~TEMPLATE.squish
        \\[quote=(?:%<from_short_key>s)%<basis_prefix_option>s%<from_id>s
        (?<suffix>;)
      TEMPLATE
    ),
    to_template: '[quote=%<to_short_key>s%<to_id>i%<suffix>s'
  }, {
    from_regexp_template: '\[(?:%<from_key>s)=%<basis_prefix_option>s%<from_id>s(?<suffix>;|\\])',
    to_template: '[%<to_key>s=%<to_id>i%<suffix>s',
    finalize_regexp_template: <<~TEMPLATE.squish
      (
        \\[%<to_key>s=%<to_id>i(?:;\\d+)?\\]
        (?: (?!\\[%<from_key>s).)*?
      )
      \\[/%<from_key>s\\]
    TEMPLATE
  }, {
    from_regexp_template: '(?<=^| )>\?%<from_short_key>s%<from_id>s(?<suffix>;)',
    to_template: '>?%<to_short_key>s%<to_id>i%<suffix>s'
  }]

  def call
    QUOTE_REPLACEMENT_TEMPLATES.inject(@text) do |memo, replacement|
      do_replace memo, replacement
    end
  end

private

  def do_replace text, replacement
    from_regexp = Regexp.new format_from_template(replacement), Regexp::EXTENDED
    is_replaced = false

    replaced_text = text.gsub(from_regexp) do
      is_replaced = true
      format_to_template replacement, $LAST_MATCH_INFO[:suffix]
    end

    if is_replaced && replacement[:finalize_regexp_template]
      finalize_regexp = Regexp.new format_finalize_template(replacement), Regexp::EXTENDED
      replaced_text.gsub finalize_regexp, "\\1[/#{to_key}]"
    else
      replaced_text
    end
  end

  def format_from_template replacement
    format replacement[:from_regexp_template],
      from_id: @from_reply.id,
      from_key: from_key,
      from_short_key: short_key(from_key),
      basis_prefix_option: basis_prefix_option(from_key)
  end

  def format_to_template replacement, suffix
    format replacement[:to_template],
      to_id: @to_reply.id,
      to_key: to_key,
      to_short_key: short_key(to_key),
      suffix: suffix
  end

  def format_finalize_template replacement
    format replacement[:finalize_regexp_template],
      to_id: @to_reply.id,
      to_key: to_key,
      from_key: from_key
  end

  def from_key
    @from_key ||= key @from_reply
  end

  def to_key
    @to_key ||= key @to_reply
  end

  def key model
    model.class.base_class.name.downcase
  end

  def short_key key
    key[0]
  end

  def basis_prefix_option key
    key == 'comment' ? '?' : ''
  end
end
