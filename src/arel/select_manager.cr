require "./collectors/sql_string"

module Arel
  class SelectManager < Arel::TreeManager
    include Arel::Crud

    def initialize(table : Arel::Table)
      super()
      @ast   = Nodes::SelectStatement.new
      @ctx    = @ast.cores.last
      from table
    end

    def initialize_copy(other)
      super
      @ctx = @ast.cores.last
    end

    def limit
      @ast.limit && @ast.limit.expr
    end
    alias_method :taken, :limit

    def constraints
      @ctx.wheres
    end

    def offset
      @ast.offset && @ast.offset.expr
    end

    def skip(amount)
      if amount
        @ast.offset = Nodes::Offset.new(amount)
      else
        @ast.offset = nil
      end
      self
    end

    ###
    # Produces an Arel::Nodes::Exists node
    def exists
      Arel::Nodes::Exists.new @ast
    end

    def as_name(other)
      create_table_alias grouping(@ast), Nodes::SqlLiteral.new(other)
    end

    def lock(locking = Arel.sql("FOR UPDATE"))
      case locking
      when true
        locking = Arel.sql("FOR UPDATE")
      when Arel::Nodes::SqlLiteral
      when String
        locking = Arel.sql locking
      end

      @ast.lock = Nodes::Lock.new(locking)
      self
    end

    def locked
      @ast.lock
    end

    def on(*exprs)
      @ctx.source.right.last.right = Nodes::On.new(collapse(exprs))
      self
    end

    def group(*columns)
      columns.each do |column|
        # FIXME: backwards compat
        column = Nodes::SqlLiteral.new(column) if String === column
        column = Nodes::SqlLiteral.new(column.to_s) if Symbol === column

        @ctx.groups.push Nodes::Group.new column
      end
      self
    end

    def from(table)
      table = Nodes::SqlLiteral.new(table) if String === table

      case table
      when Nodes::Join
        @ctx.source.right << table
      else
        @ctx.source.left = table
      end

      self
    end

    def froms
      @ast.cores.map { |x| x.from }.compact
    end

    def join(relation, klass = Nodes::InnerJoin)
      return self unless relation

      case relation
      when String, Nodes::SqlLiteral
        raise if relation.empty?
        klass = Nodes::StringJoin
      end

      @ctx.source.right << create_join(relation, nil, klass)
      self
    end

    def outer_join(relation)
      join(relation, Nodes::OuterJoin)
    end

    def having(expr)
      @ctx.havings << expr
      self
    end

    def window(name)
      window = Nodes::NamedWindow.new(name)
      @ctx.windows.push window
      window
    end

    def project(*projections)
      @ctx.projections.concat projections.map { |x|
        STRING_OR_SYMBOL_CLASS.include?(x.class) ? Nodes::SqlLiteral.new(x.to_s) : x
      }
      self
    end

    def projections
      @ctx.projections
    end

    def projections=(projections)
      @ctx.projections = projections
    end

    def distinct(value = true)
      if value
        @ctx.set_quantifier = Arel::Nodes::Distinct.new
      else
        @ctx.set_quantifier = nil
      end
      self
    end

    def distinct_on(value)
      if value
        @ctx.set_quantifier = Arel::Nodes::DistinctOn.new(value)
      else
        @ctx.set_quantifier = nil
      end
      self
    end

    def order(*expr)
      @ast.orders.concat expr.map { |x|
        STRING_OR_SYMBOL_CLASS.include?(x.class) ? Nodes::SqlLiteral.new(x.to_s) : x
      }
      self
    end

    def orders
      @ast.orders
    end

    def where_sql(engine = Table.engine)
      return if @ctx.wheres.empty?

      viz = Visitors::WhereSql.new(engine.connection.visitor, engine.connection)
      Nodes::SqlLiteral.new viz.accept(@ctx, Collectors::SQLString.new).value
    end

    def union(operation, other = nil)
      if other
        node_class = Nodes.const_get("Union#{operation.to_s.capitalize}")
      else
        other = operation
        node_class = Nodes::Union
      end

      node_class.new self.ast, other.ast
    end

    def intersect(other)
      Nodes::Intersect.new ast, other.ast
    end

    def except(other)
      Nodes::Except.new ast, other.ast
    end
    alias_method :minus, :except

    def with(*subqueries)
      if subqueries.first.is_a? Symbol
        node_class = Nodes.const_get("With#{subqueries.shift.to_s.capitalize}")
      else
        node_class = Nodes::With
      end
      @ast.with = node_class.new(subqueries.flatten)

      self
    end

    def take(limit)
      if limit
        @ast.limit = Nodes::Limit.new(limit)
        @ctx.top   = Nodes::Top.new(limit)
      else
        @ast.limit = nil
        @ctx.top   = nil
      end
      self
    end

    def join_sources
      @ctx.source.right
    end

    def source
      @ctx.source
    end
  end
end
