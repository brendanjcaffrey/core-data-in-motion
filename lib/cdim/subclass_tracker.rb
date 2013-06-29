module CDIM
  module SubclassTracker
    extend MotionSupport::Concern

    module ClassMethods
      # track all subclasses (this only works for direct children TODO recurse?)
      def inherited(subclass)
        @subclasses ||= []
        @subclasses << subclass

        # define the subclass of NSManagedObject that CoreData needs
        # prepend it with CDIM because we can't use the same class name
        Object.const_set('CDIM' + subclass.to_s,
          Class.new(NSManagedObject) do
          end
        )
      end

      def subclasses
        @subclasses ||= []
      end
    end
  end
end
