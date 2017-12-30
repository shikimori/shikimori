class MangasIndex < ApplicationIndex
  define_type Manga.where.not(type: Ranobe.name) do
  end
end
