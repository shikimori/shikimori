require 'i18n'

module I18n
  def self.time_part count, part
    "%s %s" % [count, Russian.p(count, *t("datetime.parts.#{part}").values)]
  end
end
