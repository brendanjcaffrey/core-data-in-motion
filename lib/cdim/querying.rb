module CDIM
  module Querying
    extend MotionSupport::Concern
    
    module ClassMethods
      def all
        Queryable.initialize_query(self.entity_name, self, :all)
      end

      def first(column = nil)
        Queryable.initialize_query(self.entity_name, self, :first, column)
      end

      def last(column = nil)
        Queryable.initialize_query(self.entity_name, self, :last, column)
      end

      def limit(amount)
        Queryable.initialize_query(self.entity_name, self, :limit, amount)
      end
    end
  end
end
