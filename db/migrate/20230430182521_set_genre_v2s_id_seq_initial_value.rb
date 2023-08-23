class SetGenreV2sIdSeqInitialValue < ActiveRecord::Migration[6.1]
  def change
    execute %q[
      select setval('genre_v2s_id_seq', 100);
    ]
    reversible do |dir|
      dir.up do
        GenreV2.destroy_all
      end
    end
  end
end
