module Bitty
  class BitProxy
    def self.bit_names=(names)
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
    end
  end
end
