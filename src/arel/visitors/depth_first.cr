module Arel
  module Visitors
    class DepthFirst < Arel::Visitors::Visitor
      def initialize(block : Proc?)
        @block = block || Proc.new
        previous_def
      end


      private def visit(o)
        previous_def(o)
        @block.call o
      end

      private def unary(o)
        visit o.expr
      end
      alias_method :visit_Arel_Nodes_Else             ,  :unary
      alias_method :visit_Arel_Nodes_Group            ,  :unary
      alias_method :visit_Arel_Nodes_Grouping         ,  :unary
      alias_method :visit_Arel_Nodes_Having           ,  :unary
      alias_method :visit_Arel_Nodes_Limit            ,  :unary
      alias_method :visit_Arel_Nodes_Not              ,  :unary
      alias_method :visit_Arel_Nodes_Offset           ,  :unary
      alias_method :visit_Arel_Nodes_On               ,  :unary
      alias_method :visit_Arel_Nodes_Ordering         ,  :unary
      alias_method :visit_Arel_Nodes_Ascending        ,  :unary
      alias_method :visit_Arel_Nodes_Descending       ,  :unary
      alias_method :visit_Arel_Nodes_Top              ,  :unary
      alias_method :visit_Arel_Nodes_UnqualifiedColumn,  :unary

      private def function(o)
        visit o.expressions
        visit o.alias
        visit o.distinct
      end
      alias_method :visit_Arel_Nodes_Avg    , :function
      alias_method :visit_Arel_Nodes_Exists , :function
      alias_method :visit_Arel_Nodes_Max    , :function
      alias_method :visit_Arel_Nodes_Min    , :function
      alias_method :visit_Arel_Nodes_Sum    , :function

      private def visit_Arel_Nodes_NamedFunction(o)
        visit o.name
        visit o.expressions
        visit o.distinct
        visit o.alias
      end

      private def visit_Arel_Nodes_Count(o)
        visit o.expressions
        visit o.alias
        visit o.distinct
      end

      private def visit_Arel_Nodes_Case(o)
        visit o.case
        visit o.conditions
        visit o.default
      end

      private def nary(o)
        o.children.each { |child| visit child}
      end
      alias_method :visit_Arel_Nodes_And, :nary

      private def binary(o)
        visit o.left
        visit o.right
      end
      alias_method :visit_Arel_Nodes_As                 , :binary
      alias_method :visit_Arel_Nodes_Assignment         , :binary
      alias_method :visit_Arel_Nodes_Between            , :binary
      alias_method :visit_Arel_Nodes_Concat             , :binary
      alias_method :visit_Arel_Nodes_DeleteStatement    , :binary
      alias_method :visit_Arel_Nodes_DoesNotMatch       , :binary
      alias_method :visit_Arel_Nodes_Equality           , :binary
      alias_method :visit_Arel_Nodes_FullOuterJoin      , :binary
      alias_method :visit_Arel_Nodes_GreaterThan        , :binary
      alias_method :visit_Arel_Nodes_GreaterThanOrEqual , :binary
      alias_method :visit_Arel_Nodes_In                 , :binary
      alias_method :visit_Arel_Nodes_InfixOperation     , :binary
      alias_method :visit_Arel_Nodes_JoinSource         , :binary
      alias_method :visit_Arel_Nodes_InnerJoin          , :binary
      alias_method :visit_Arel_Nodes_LessThan           , :binary
      alias_method :visit_Arel_Nodes_LessThanOrEqual    , :binary
      alias_method :visit_Arel_Nodes_Matches            , :binary
      alias_method :visit_Arel_Nodes_NotEqual           , :binary
      alias_method :visit_Arel_Nodes_NotIn              , :binary
      alias_method :visit_Arel_Nodes_NotRegexp          , :binary
      alias_method :visit_Arel_Nodes_Or                 , :binary
      alias_method :visit_Arel_Nodes_OuterJoin          , :binary
      alias_method :visit_Arel_Nodes_Regexp             , :binary
      alias_method :visit_Arel_Nodes_RightOuterJoin     , :binary
      alias_method :visit_Arel_Nodes_TableAlias         , :binary
      alias_method :visit_Arel_Nodes_Union              , :binary
      alias_method :visit_Arel_Nodes_Values             , :binary
      alias_method :visit_Arel_Nodes_When               , :binary

      private def visit_Arel_Nodes_StringJoin(o)
        visit o.left
      end

      private def visit_Arel_Attribute(o)
        visit o.relation
        visit o.name
      end
      alias_method :visit_Arel_Attributes_Integer, :visit_Arel_Attribute
      alias_method :visit_Arel_Attributes_Float, :visit_Arel_Attribute
      alias_method :visit_Arel_Attributes_String, :visit_Arel_Attribute
      alias_method :visit_Arel_Attributes_Time, :visit_Arel_Attribute
      alias_method :visit_Arel_Attributes_Boolean, :visit_Arel_Attribute
      alias_method :visit_Arel_Attributes_Attribute, :visit_Arel_Attribute
      alias_method :visit_Arel_Attributes_Decimal, :visit_Arel_Attribute

      private def visit_Arel_Table(o)
        visit o.name
      end

      private def terminal(o)
      end
      alias_method :visit_ActiveSupport_Multibyte_Chars , :terminal
      alias_method :visit_ActiveSupport_StringInquirer  , :terminal
      alias_method :visit_Arel_Nodes_Lock               , :terminal
      alias_method :visit_Arel_Nodes_Node               , :terminal
      alias_method :visit_Arel_Nodes_SqlLiteral         , :terminal
      alias_method :visit_Arel_Nodes_BindParam          , :terminal
      alias_method :visit_Arel_Nodes_Window             , :terminal
      alias_method :visit_Arel_Nodes_True               , :terminal
      alias_method :visit_Arel_Nodes_False              , :terminal
      alias_method :visit_BigDecimal                    , :terminal
      alias_method :visit_Bignum                        , :terminal
      alias_method :visit_Class                         , :terminal
      alias_method :visit_Date                          , :terminal
      alias_method :visit_DateTime                      , :terminal
      alias_method :visit_FalseClass                    , :terminal
      alias_method :visit_Fixnum                        , :terminal
      alias_method :visit_Float                         , :terminal
      alias_method :visit_NilClass                      , :terminal
      alias_method :visit_String                        , :terminal
      alias_method :visit_Symbol                        , :terminal
      alias_method :visit_Time                          , :terminal
      alias_method :visit_TrueClass                     , :terminal

      private def visit_Arel_Nodes_InsertStatement(o)
        visit o.relation
        visit o.columns
        visit o.values
      end

      private def visit_Arel_Nodes_SelectCore(o)
        visit o.projections
        visit o.source
        visit o.wheres
        visit o.groups
        visit o.windows
        visit o.havings
      end

      private def visit_Arel_Nodes_SelectStatement(o)
        visit o.cores
        visit o.orders
        visit o.limit
        visit o.lock
        visit o.offset
      end

      private def visit_Arel_Nodes_UpdateStatement(o)
        visit o.relation
        visit o.values
        visit o.wheres
        visit o.orders
        visit o.limit
      end

      private def visit_Array(o)
        o.each { |i| visit i }
      end
      alias_method :visit_Set, :visit_Array

      private def visit_Hash(o)
        o.each { |k,v| visit(k); visit(v) }
      end

      DISPATCH = dispatch_cache

      private def get_dispatch_cache
        DISPATCH
      end
    end
  end
end
