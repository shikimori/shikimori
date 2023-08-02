class Types::Scalars::SeasonString < Types::StringType
  description SOMMA_SEPARATED_DESCRIPTION + <<~TEXT
    **Examples:**

    `summer_2017`

    `2016`

    `2014_2016`

    `199x`
  TEXT
end
