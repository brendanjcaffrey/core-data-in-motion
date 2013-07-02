module CDIM
  module SubclassTracker
    extend MotionSupport::Concern

    module ClassMethods
      # track all subclasses (this only works for direct children TODO recurse?)
      def inherited(subclass)
        @subclasses ||= []
        @subclasses << subclass

        define_managed_subclass(subclass)
      end

      def subclasses
        @subclasses ||= []
      end
    end
  end
end
