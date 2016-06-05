class AddLocaleFromDomainAndRenameLanguageToLocaleInUsers < ActiveRecord::Migration
  def up
    add_column :users, :locale_from_domain, :string, default: :ru, null: false
    rename_column :users, :language, :locale

    change_column_default :users, :locale, :ru
    change_column_null :users, :locale, false

    User.where(locale: :russian).update_all locale: :ru
    User.where(locale: :english).update_all locale: :en
  end

  def down
    User.where(locale: :ru).update_all locale: :russian
    User.where(locale: :en).update_all locale: :english

    change_column_default :users, :locale, :russian
    change_column_null :users, :locale, true

    rename_column :users, :locale, :language
    remove_column :users, :locale_from_domain
  end
end
