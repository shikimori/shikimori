# https://github.com/rs-pro/russian/blob/master/lib/russian/locale/datetime.rb
{
  ru: {
    date: {
      abbr_day_names: lambda { |key, options|
        if options[:format] && options[:format] =~ Russian::LOCALIZE_STANDALONE_ABBR_DAY_NAMES_MATCH
          :'date.common_abbr_day_names'
        else
          :'date.standalone_abbr_day_names'
        end
      },
      day_names: lambda { |key, options|
        if options[:format] && options[:format] =~ Russian::LOCALIZE_STANDALONE_DAY_NAMES_MATCH
          :'date.standalone_day_names'
        else
          :'date.common_day_names'
        end
      },
      abbr_month_names: lambda { |key, options|
        if options[:format] && options[:format] =~ Russian::LOCALIZE_ABBR_MONTH_NAMES_MATCH
          :'date.common_abbr_month_names'
        else
          :'date.standalone_abbr_month_names'
        end
      },
      month_names: lambda { |key, options|
        if options[:format] && options[:format] =~ Russian::LOCALIZE_MONTH_NAMES_MATCH
          :'date.common_month_names'
        else
          :'date.standalone_month_names'
        end
      },
      common_abbr_month_names: [
        nil,
        'янв.',
        'февр.',
        'марта',
        'апр.',
        'мая',
        'июня',
        'июля',
        'авг.',
        'сент.',
        'окт.',
        'нояб.',
        'дек.'
      ]
    }
  }
}
