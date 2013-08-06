module CDIM
  class Queryable < BasicObject
    def self.initialize_query(entity_name, model_class, filter, args = nil)
      queryable = Queryable.new(entity_name, model_class)

      if args != nil
        queryable.__send__(filter, args)
      else
        queryable.__send__(filter)
      end
    end

    def initialize(entity_name, model_class)
      @model_class = model_class
      @request = CDIMFetchRequest.fetchRequestWithEntityName(entity_name)
    end

    def all
      self
    end

    def first(column = nil)
      if column != nil
        verify_column(column)
        add_sort_descriptor(column, :ascending)
      end

      @request.fetchLimit = 1
      self
    end

    def last(column = nil)
      column = 'created_at' if column == nil && has_column('created_at')

      if column != nil
        verify_column(column)
        add_sort_descriptor(column, :descending)
        @request.fetchLimit = 1
      else
        @request.should_return_only_last = true
      end

      self
    end

    def limit(amount)
      @request.fetchLimit = amount
      self
    end

    def method_missing(name, *arguments, &block)
      if get_collection.respond_to? name
        get_collection.send(name, *arguments, &block)
      else
        super
      end
    end

    def respond_to_missing(name)
      get_collection.respond_to? name
    end

    private

    def get_collection
      @collection ||= begin
        add_sort_descriptor('created_at', :ascending) if @request.sortDescriptors == nil && has_column('created_at')
        ret = Store.shared.execute_fetch_request(@request)

        if @request.fetchLimit == 1
          @model_class.new(ret.first)
        elsif @request.should_return_only_last
          @model_class.new(ret.last)
        else
          ret.map { |item| @model_class.new(item) }
        end
      end
    end

    def add_sort_descriptor(column, direction)
      descriptors = @request.sortDescriptors == nil ? NSMutableArray.new : @request.sortDescriptors.mutableCopy
      new_descriptor = NSSortDescriptor.sortDescriptorWithKey(column, ascending:direction == :ascending)

      descriptors.addObject(new_descriptor)
      @request.sortDescriptors = descriptors
    end

    def verify_columns(columns)
      columns.map(&:verify_column)
    end

    def verify_column(column)
        ::Kernel.raise ::ArgumentError.new('Model ' + @model_class.to_s + ' does not contain column '  + column.to_s) unless has_column(column)
    end

    def has_column(column)
      @model_class.attributes[column] != nil
    end
  end

  class CDIMFetchRequest < NSFetchRequest
    attr_accessor :should_return_only_last
  end
end
