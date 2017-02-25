class RenameLocaleFromDomainToLocaleFromHostInUsers < ActiveRecord::Migration
  def change
    rename_column :users, :locale_from_domain, :locale_from_host
  end
end
