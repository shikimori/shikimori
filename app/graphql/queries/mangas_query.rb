class Queries::MangasQuery < Queries::BaseQuery
  type [Types::MangaType], null: false

  argument :page, Integer, required: false, default_value: 1
  argument :limit, Integer, required: false, default_value: 2
  argument :order, Types::Enums::OrderEnum, required: false, default_value: 'ranked'
  argument :kind, Types::Scalars::KindString, required: false
  argument :status, Types::Scalars::StatusString, required: false
  argument :score, Integer,
    required: false,
    description: 'Minimal manga score'
  argument :genre, String,
    required: false,
    description: 'List of comma separated genre ids'
  argument :publisher, String,
    required: false,
    description: 'List of comma separated publisher ids'
  argument :franchise, String,
    required: false,
    description: 'List of comma separated franchises'
  argument :censored, Boolean,
    required: false,
    description: 'Set to `false` to allow hentai, yaoi and yuri'
  argument :mylist, Types::Scalars::MylistString, required: false
  argument :ids, String,
    required: false,
    description: 'List of comma separated ids'
  argument :exclude_ids, String,
    required: false,
    description: 'List of comma separated ids'
  argument :search, String, required: false

  LIMIT = 50

  def resolve( # rubocop:disable Metrics/ParameterLists, Metrics/MethodLength
    page:,
    limit:,
    order:,
    kind: nil,
    status: nil,
    score: nil,
    genre: nil,
    publisher: nil,
    franchise: nil,
    censored: nil,
    mylist: nil,
    ids: nil,
    exclude_ids: nil,
    search: nil
  )
    AnimesCollection::PageQuery
      .call(
        klass: Manga,
        filters: {
          page: page,
          order: order,
          score: score,
          kind: kind,
          status: status,
          genre: genre,
          publisher: publisher,
          franchise: franchise,
          censored: censored,
          mylist: mylist,
          ids: ids,
          exclude_ids: exclude_ids,
          search: search
        },
        user: current_user,
        limit: limit.to_i.clamp(1, LIMIT)
      )
      .collection
  end
end
