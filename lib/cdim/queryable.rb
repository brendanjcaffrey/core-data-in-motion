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

    def first(amount = 1)
      @request.fetchLimit = amount
      self
    end

    def last(amount = 1)
      @request.should_return_only_last = amount
      self
    end

    def limit(amount)
      @request.fetchLimit = amount
      self
    end

    def order(column_order)
      column, order = extract_column_order(column_order)

      verify_column(column)
      add_sort_descriptor(column, order)
      self
    end

    def none
      @none = true
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
        return [] if @none

        add_sort_descriptor('created_at', :ascending) if @request.sortDescriptors == nil && has_column('created_at')
        ret = Store.shared.execute_fetch_request(@request)

        if @request.fetchLimit == 1
          @model_class.new(ret.first)
        elsif @request.should_return_only_last == 1
          @model_class.new(ret.last)
        elsif @request.should_return_only_last
          ret.last(@request.should_return_only_last).map { |item| @model_class.new(item) }
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

    def extract_column_order(column_order)
      return column_order, :ascending if column_order.index(' ') == nil

      split = column_order.split(' ')
      return split[0], (split[1].downcase == 'ascending' ? :ascending : :descending)
    end
  end

  class CDIMFetchRequest < NSFetchRequest
    attr_accessor :should_return_only_last
  end
end
