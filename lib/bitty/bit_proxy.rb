module Bitty
  # This class acts like a proxy. It presents you with all these
  # bitfield methods, but it doesn't store the value itself.
  class BitProxy
    # this will be redefined in self.column=
    def initialize(*args)
    end

    class <<self
      attr_reader :power2

      def bit_names=(names)
        @power2 = {}
        p = 1

        names.each do |name|
          n = name.to_sym

          if @power2.include?(n)
            raise ArgumentError, "Bit name #{n} repeated more that once!"
          else
            @power2[n] = p
            p <<= 1
          end
        end

        @power2.each do |name, bitmask|
          inv = ~bitmask
          class_eval <<-RUBY
            def #{name}
              (value & #{bitmask}) != 0
            end

            alias #{name}? #{name}

            def #{name}=(val)
              self.value = true?(val) ? (value | #{bitmask}) : (value & #{inv})
            end
          RUBY
        end
      end

      def column=(column)
        class_eval <<-RUBY
          attr_accessor :model_object

          def initialize(model_object)
            self.model_object = model_object

            super
          end

          def value
            model_object[:#{column}]
          end

          def value=(newval)
            model_object[:#{column}] = newval
          end
        RUBY
      end

      def named_scope(*args)
        # TODO: named_scope
      end
    end

    def [](key)
      bitmask = power2(key)

      if bitmask
        (value & bitmask) != 0
      else
        nil
      end
    end

    def []=(key, val)
      bitmask = power2(key)
      raise ArgumentError, "unknown bitname: #{key}" unless bitmask

      self.value = true?(val) ? (value | bitmask) : (value & ~bitmask)
    end

    def set!(value)
      case value
      when Array
        value.each { |key| self[key] = true }
      when Hash
        value.each { |key, val| self[key] = val }
      when Fixnum
        self.value = value
      else
        raise ArgumentError, "invalid value (must be Array/Hash/Fixnum)"
      end
    end

    protected

    # this will be redefined in self.column=
    def value
      raise
    end

    # this will be redefined in self.column=
    def value=(newval)
      raise
    end

    # power of 2, corresponding to key
    def power2(key)
      self.class.power2[key.to_sym]
    end

    def true?(val)
      case val
      when true, 1, /1|y|yes/i then true
      else false
      end
    end
  end
end
