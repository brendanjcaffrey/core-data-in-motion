module CDIM
  # the overarching goal of this class is to never touch the managed object or never create one until we know that it is being saved
  # calling save on a persistent store saves every CoreData object that's been modified, so avoiding modifying them unless they're being saved is the best bet here
  class Model
    attr_reader :managed_object, :orphaned, :changes, :collections

    include Entity
    include Properties
    include Persistence
    include SubclassTracker
    include Querying
  end
end

