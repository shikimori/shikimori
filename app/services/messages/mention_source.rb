class Messages::MentionSource
  include Translation

  method_object :linked, %i[comment_id is_simple]
  delegate :mention_url, to: :class

  SUPPORTED_MENTION_TYPES = {
    Article => :article,
    ClubPage => :topic,
    Collection => :collection,
    Comment => :comment,
    Critique => :critique,
    Review => :review,
    Topic => :topic,
    User => :profile
  }

  def self.mention_url linked
    return unless linked

    method_name = SUPPORTED_MENTION_TYPES[linked.class.base_class] ||
      raise(ArgumentError, "#{linked.class} #{linked.to_param}")

    UrlGenerator.instance.send :"#{method_name}_url", linked
  end

  def call
    i18n_t(
      i18n_key,
      name: ERB::Util.h(linked_name),
      url: "#{mention_url @linked}#{comment_hash}",
      bubble: link_bubble
    ).html_safe
  end

private

  def i18n_key
    "#{i18n_primary_key}_mention.#{i18n_secondary_key}"
  end

  def i18n_primary_key
    is_simple ? :simple : :text
  end

  def i18n_secondary_key
    return :nil unless @linked

    SUPPORTED_MENTION_TYPES[@linked.class.base_class] ||
      raise(ArgumentError, "#{@linked.class} #{@linked.to_param}")
  end

  def linked_name
    case @linked
      when Topic
        @linked.respond_to?(:full_title) ?
          @linked.full_title :
          @linked.title

      when User
        @linked.nickname

      when Critique
        @linked.target.name

      when Review
        @linked.db_entry.name

      when Article
        @linked.name
    end
  end

  def comment_hash
    "#comment-#{@comment_id}" if @comment_id
  end

  def link_bubble
    url =
      if @comment_id
        UrlGenerator.instance.tooltip_comment_url @comment_id
      elsif @linked.is_a?(Topic) || @linked.is_a?(Review) || @linked.is_a?(Critique)
        "#{mention_url @linked}/tooltip"
      end

    " class=\"bubbled b-link\" data-href=\"#{url}\"" if url
  end
end
