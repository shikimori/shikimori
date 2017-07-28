class ListImports::ListEntry < Dry::Struct
  attribute :target_title, Types::Strict::String
  attribute :target_id, Types::Coercible::Int
  attribute :target_type, Types::Strict::String.enum('Anime', 'Manga')
  attribute :score, Types::Coercible::Int
  attribute :status, Types::UserRate::Status
  attribute :rewatches, Types::Coercible::Int
  attribute :episodes, Types::Coercible::Int.optional
  attribute :volumes, Types::Coercible::Int.optional
  attribute :chapters, Types::Coercible::Int.optional
  attribute :text, Types::SpentTime.optional
end
