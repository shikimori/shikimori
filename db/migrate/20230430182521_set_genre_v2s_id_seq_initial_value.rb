class SetGenreV2sIdSeqInitialValue < ActiveRecord::Migration[6.1]
  def change
    execute %q[
      select setval('genres_v2_id_seq', 100);
    ]
    reversible do |dir|
      dir.up do
        GenreV2.destroy_all
      end
    end
  end
end
