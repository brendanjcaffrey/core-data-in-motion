# stolen from https://gist.github.com/seanlilmateus/5641989
module CDIM::CollectionManager::Forwardable
  def def_instance_delegator(accessor, method, ali = method)
    accessor = accessor.id2name if accessor.kind_of?(Integer)
    method = method.id2name if method.kind_of?(Integer)
    ali = ali.id2name if ali.kind_of?(Integer)
    activity = Proc.new do
      define_method("#{ali}") do |*args, &block|
        begin
          instance_variable_get(accessor).__send__(method, *args, &block)
        rescue Exception
          $@.delete_if{|s| %r"#{Regexp.quote(__FILE__)}"o =~ s} unless Forwardable::debug
          Kernel::raise
        end
      end
    end
    
    # If it's not a class or module, it's an instance
    begin
      module_eval(&activity)
    rescue
      instance_eval(&activity)
    end
  end
  
  alias def_delegator def_instance_delegator
end

