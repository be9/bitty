require File.join(File.dirname(__FILE__), 'bitty', 'bit_proxy')

module Bitty
  module ActiveRecordExtensions
    def bitty(field, *args)
      field = field.to_sym

      opts = args.extract_options!

      proxy = Class.new(Bitty::BitProxy)
      proxy.bit_names = args
      proxy.column = opts[:column] || field

      # TODO: opts[:default]
      # TODO: opts[:named_scope]
      # TODO: check if field has already been defined in superclass
      write_inheritable_hash(:_bitty_fields, { field => proxy } )

      class_eval <<-RUBY
        def #{field}
          @_bitty_#{field} ||=
            self.class.read_inheritable_attribute(:_bitty_fields)[:#{field}].new(self)
        end

        def #{field}=(value)
          #{field}.set!(value)
        end
      RUBY
    end

    def bitty_named_scope(name, bitty_field, *args)
      proxy_class = read_inheritable_attribute(:_bitty_fields)[bitty_field]

      if proxy_class
        named_scope name, proxy_class.named_scope(*args)
      else
        raise ArgumentError, "There's no bitfield '#{bitty_field}' defined!"
      end
    end
  end
end

if defined? ActiveRecord::Base
  ActiveRecord::Base.send(:extend, Bitty::ActiveRecordExtensions)
end
