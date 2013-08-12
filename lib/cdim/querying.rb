module CDIM
  module Querying
    extend MotionSupport::Concern
    
    module ClassMethods
      NO_ARGUMENT = [:all]
      OPTIONAL_ARGUMENT = [:first, :last]
      ONE_ARGUMENT = [:limit]

      NO_ARGUMENT.each do |method|
        define_method method do
          Queryable.initialize_query(self.entity_name, self, method, nil)
        end
      end

      OPTIONAL_ARGUMENT.each do |method|
        define_method method do |arg = nil|
          Queryable.initialize_query(self.entity_name, self, method, arg)
        end
      end

      ONE_ARGUMENT.each do |method|
        define_method method do |arg|
          Queryable.initialize_query(self.entity_name, self, method, arg)
        end
      end
    end
  end
end
