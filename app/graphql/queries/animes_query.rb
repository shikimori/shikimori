class Queries::AnimesQuery < Queries::BaseQuery
  type [Types::AnimeType], null: false

  argument :page, Integer, required: false, default_value: 1
  argument :limit, Integer, required: false, default_value: 2

  # ORDERS = %w[
  #   id id_desc ranked kind popularity name aired_on episodes status
  #   random ranked_random ranked_shiki
  #   created_at created_at_desc
  # ]
  # ORDERS_DESC = ORDERS.inject('') do |memo, order|
  #   memo + <<~DOC
  #     <p><code>#{order}</code> &ndash;
  #     #{I18n.t("by.#{order}", locale: :en).downcase}#{'. <b>Will be removed. Do not use it.</b>' if order.include? 'ranked_'}
  #     </p>
  #   DOC
  # rescue I18n::NoTranslation
  #   memo
  # end
  # api :GET, '/animes', 'List animes'
  # description: <<~DOC
  #   <p>
  #     Most of parameters can be grouped in lists of values separated by comma:
  #     <ul>
  #       <li>
  #         <code>season=2016,2015</code> &ndash;
  #         animes with season <code>2016 year</code>
  #         or with season <code>2015 year</code>
  #       </li>
  #       <li>
  #         <code>kind=tv,movie</code> &ndash;
  #         animes with kind <code>TV</code> or with kind <code>Movie</code>
  #       </li>
  #     </ul>
  #   </p>
  #   <p>
  #     Most of the parameters can be used in the subtraction mode:
  #     <ul>
  #       <li>
  #         <code>season=!2016,!2015</code> &ndash;
  #         animes without season <code>2016 year</code>
  #         and without season <code>2015 year</code>
  #       </li>
  #       <li>
  #         <code>kind=!tv,!movie</code> &ndash;
  #         animes without kind <code>TV</code>
  #         and without kind <code>Movie</code>
  #       </li>
  #     </ul>
  #   </p>
  #   <p>
  #     Most of the parameters can be used in the combined mode:
  #     <ul>
  #       <li>
  #         <code>season=2016,!summer_2016</code> &ndash;
  #         animes with season <code>2016 year</code> and
  #         without season <code>summer_2016</code>
  #       </li>
  #     </ul>
  #   </p>
  # DOC
  argument :order, Types::Enums::OrderEnum, required: false
  argument :kind, Types::Scalars::KindString, required: false
  argument :status, Types::Scalars::StatusString, required: false
  argument :season, Types::Scalars::SeasonString, required: false
  argument :score, Integer,
    required: false,
    description: 'Minimal anime score'
  argument :duration, Types::Scalars::DurationString, required: false
  argument :rating, Types::Scalars::RatingString, required: false
  argument :genre, String,
    required: false,
    description: 'List of comma separated genre ids'
  argument :studio, String,
    required: false,
    description: 'List of comma separated studio ids'
  argument :franchise, String,
    required: false,
    description: 'List of comma separated franchises'
  argument :censored, Boolean,
    required: false,
    description: 'Set to `false` to allow hentai, yaoi and yuri'
  # argument :mylist, String,
  #   required: false,
  #   description: <<~DOC
  #     <p>Status of manga in current user list</p>
  #     <p><strong>Validations:</strong></p>
  #     <ul>
  #       <li>
  #         Must be one of:
  #         <code>#{UserRate.statuses.keys.join('</code>, <code>')}</code>
  #       </li>
  #     </ul>
  #   DOC
  # argument :ids, String,
  #   required: false,
  #   description: 'List of anime ids separated by comma'
  # argument :exclude_ids, String,
  #   required: false,
  #   description: 'List of anime ids separated by comma'
  argument :search, String, required: false

  LIMIT = 50

  def resolve( # rubocop:disable Metrics/ParameterLists, Metrics/MethodLength
    page:,
    limit:,
    order:,
    kind: nil,
    status: nil,
    season: nil,
    score: nil,
    duration: nil,
    rating: nil,
    genre: nil,
    studio: nil,
    franchise: nil,
    censored: nil,
    search: nil
  )
    AnimesCollection::PageQuery
      .call(
        klass: Anime,
        filters: {
          page: page,
          order: order,
          score: score,
          kind: kind,
          status: status,
          season: season,
          duration: duration,
          rating: rating,
          genre: genre,
          studio: studio,
          franchise: franchise,
          censored: censored,
          search: search
        },
        user: current_user,
        limit: limit.to_i.clamp(1, LIMIT)
      )
      .collection
  end
end
