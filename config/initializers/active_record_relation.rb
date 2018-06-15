module ActiveRecord::RelationExtension
  def to_where_sql
    to_sql.sub(/^.* WHERE |(?:ORDER|GROUP|HAVING).*/, '')
    # arel.ast.cores.first.wheres.first.to_sql
  end
end

ActiveRecord::Relation.send :include, ActiveRecord::RelationExtension
