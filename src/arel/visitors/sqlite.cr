module Arel
  module Visitors
    class SQLite < Arel::Visitors::ToSql

      # Locks are not supported in SQLite
      private def visit_Arel_Nodes_Lock(o, collector)
        collector
      end

      private def visit_Arel_Nodes_SelectStatement(o, collector)
        o.limit = Arel::Nodes::Limit.new(-1) if o.offset && !o.limit
        super
      end
    end
  end
end
