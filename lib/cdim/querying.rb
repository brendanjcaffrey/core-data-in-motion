module CDIM
  module Querying
    extend MotionSupport::Concern
    
    module ClassMethods
      def all
        Store.shared.get_all(self.entity_name).map { |mob| self.new(mob) }
      end

      def first(column = nil)
        Queryable.initialize_query(self.entity_name, self, :first, column)
      end

      def last(column = nil)
        Queryable.initialize_query(self.entity_name, self, :last, column)
      end
    end
  end
end
