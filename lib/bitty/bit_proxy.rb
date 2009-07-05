module Bitty
  # This class acts like a proxy. It presents you with all these
  # bitfield methods, but it doesn't store the value itself.
  def true?(val)
    case val
    when true, 1, /1|y|yes/i then true
    else false
    end
  end

  module_function :true?

  class BitProxy
    # this will be redefined in self.column=
    def initialize(*args)
    end

    class <<self
      def power2(name)
        @power2[name.to_sym]
      end

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
              self.value = Bitty.true?(val) ? (value | #{bitmask}) : (value & #{inv})
            end
          RUBY
        end
      end

      attr_reader :column

      def column=(column)
        @column = column

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
        bits = args.extract_options!
        args.each { |arg| bits[arg] = true }

        masks = [0, 0]

        bits.each do |name, val|
          mask = power2(name)
          raise ArgumentError, "invalid bit name #{name}" unless mask

          masks[Bitty.true?(val) ? 1 : 0] |= mask
        end

        cond = [nil, nil]

        if masks[0] != 0
          cond[0] = "#{column} & #{masks[0]} = 0"
        end

        if masks[1] != 0
          cond[1] = "#{column} & #{masks[1]} = #{masks[1]}"
        end

        { :conditions => cond.compact.map { |c| "(#{c})" } * ' AND ' }
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

      self.value = Bitty.true?(val) ? (value | bitmask) : (value & ~bitmask)
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
      self.class.power2(key)
    end
  end
end
