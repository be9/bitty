require File.join(File.dirname(__FILE__), 'bitty', 'bit_proxy')

module Bitty
  module ActiveRecordExtensions
    def bitty(field, *args)
      field = field.to_sym

      opts = args.extract_options!

      proxy = Class.new(Bitty::BitProxy)
      proxy.bit_names = args
      proxy.column = opts[:column] || field

      write_inheritable_hash(:_bitty_fields, { field => proxy } )

      class_eval <<-RUBY
        def #{field}
          @_bitty_#{field} ||= 
            self.class.read_inheritable_attribute(:_bitty_fields)[:#{field}].new
        end

        def #{field}=(something)
          #{field}.set(something)
        end
      RUBY
    end
  end
end

if defined? ActiveRecord::Base
  ActiveRecord::Base.send(:extend, Bitty::ActiveRecordExtensions)
end
