module CDIM
  module Persistence
    extend MotionSupport::Concern
    
    module ClassMethods
      def create(attributes = {})
        obj = self.new(attributes)
        obj.save

        obj
      end

      def build(attributes = {})
        self.new(attributes)
      end
    end

    def touch
      @dirty = true if self.class.timestamps
      save
    end

    def save
      @managed_object = self.class.object_in_context if @orphaned

      # save through first
      @collections.each { |k, v| v.save }

      if @dirty
        self.write_updated_at unless @changes[:updated_at]
        self.write_hash_to_managed_object(@changes)

        begin
          Store.shared.save
        rescue RuntimeError => e
          # if we creaetd a new NSManagedObject, we have to remove it otherwise it'll show up in calls to .all
          # (even though it didn't save and wouldn't actually persist across app launches)
          if @orphaned
            Store.shared.remove(@managed_object)
            @managed_object = nil
          end

          raise e
        end

        @dirty = false
        @changes = @changes.clear
        @orphaned = false
      end

      true
    end

    def destroy
      Store.shared.remove(@managed_object) unless @managed_object == nil

      # reset object state to disallow resaving
      @managed_object = nil
      @invalid = true
      @changes = nil
    end
    alias_method :delete, :destroy

    def new_record?
      @orphaned
    end
  end
end
