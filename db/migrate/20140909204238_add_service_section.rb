class AddServiceSection < ActiveRecord::Migration
  def up
    Section.create!(
      id: DbEntryThread::SectionIDs[Person.name],
      position: 4,
      name: 'Авторы аниме и манги',
      description: 'Обсуждение авторов аниме и манги.',
      permalink: 'p',
      meta_title: 'Форум об авторах аниме и манги',
      meta_keywords: 'авторы аниме и манги, обсуждения, дискуссии',
      meta_description: 'Форум, посвящённый авторам аниме и манги.'
    )
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
