require 'test_helper'

class ValueTester < Hash
  def value; self[:value] end
  def value=(newval)
    self[:value] = newval
  end
end

class BittyProxyTest < Test::Unit::TestCase
  before :all do
    @proxy_class = Class.new(Bitty::BitProxy)
    @proxy_class.bit_names = [:uno, :dos, :tres, :quatro]
    @proxy_class.column = :value
  end

  before do
    @mobject = ValueTester.new
    @mobject.value = 0b1010
    @foo = @proxy_class.new(@mobject)
  end

  [:to_sym, :to_s].each do |conv|
    it "should allow to query values with [bitname.#{conv}]" do
      @foo['uno'.send(conv)].should == false
      @foo['dos'.send(conv)].should == true
      @foo['tres'.send(conv)].should == false
      @foo['quatro'.send(conv)].should == true
    end

    [true, '1', 1, 'yes', 'y', 'YES'].each do |yesval|
      it "should set 1st bit with bitval['uno'.#{conv}] = #{yesval.inspect}" do
        @foo['uno'.send(conv)] = yesval
        @mobject.value.should == 0b1011
      end

      it "should set 2nd bit with bitval['dos'.#{conv}] = #{yesval.inspect}" do
        @foo['dos'.send(conv)] = yesval
        @mobject.value.should == 0b1010
      end

      it "should set 3rd bit with bitval['tres'.#{conv}] = #{yesval.inspect}" do
        @foo['tres'.send(conv)] = yesval
        @mobject.value.should == 0b1110
      end
    end

    [false, '0', 0, 'no', 'n', 'NO'].each do |noval|
      it "should reset 1st bit with bitval['uno'.#{conv}] = #{noval.inspect}" do
        @foo['uno'.send(conv)] = noval
        @mobject.value.should == 0b1010
      end

      it "should reset 2nd bit with bitval['dos'.#{conv}] = #{noval.inspect}" do
        @foo['dos'.send(conv)] = noval
        @mobject.value.should == 0b1000
      end

      it "should reset 4th bit with bitval['quatro'.#{conv}] = #{noval.inspect}" do
        @foo['quatro'.send(conv)] = noval
        @mobject.value.should == 0b0010
      end
    end
  end

  describe "#set!" do
    it "should set value given integer" do
      @foo.set! 0b1111
      @mobject.value.should == 0b1111
    end

    it "should set value given a hash of values" do
      @mobject.value = 0
      @foo.set! :uno => 1, :quatro => 'yeah'
      @mobject.value.should == 0b1001

      @mobject.value = 0b1111
      @foo.set! :dos => 0, :tres => 'N'
      @mobject.value.should == 0b1001
    end

    it "should raise ArgumentError given hash with unknown bitname" do
      @mobject.value = 0
      lambda do
        @foo.set! :uno => 1, :unknown => 'yeah'
      end.should raise_error(ArgumentError)
    end

    it "should set value given an array of set bits" do
      @mobject.value = 0
      @foo.set! [:uno, :quatro]
      @mobject.value.should == 0b1001

      @mobject.value = 0
      @foo.set! %w(dos tres)
      @mobject.value.should == 0b0110
    end

    it "should raise ArgumentError given array with unknown bitnames" do
      @mobject.value = 0
      lambda do
        @foo.set! [:uno, :unknown]
      end.should raise_error(ArgumentError)
    end

    ["yeah", 123.321, nil, true, false, 1..10].each do |crap|
      it "should raise ArgumentError given unsupported type (#{crap.inspect})" do
        lambda do
          @foo.set! crap
        end.should raise_error(ArgumentError)
      end
    end
  end

  describe "named access" do
    it "should allow to query bits directly" do
      @foo.uno.should == false
      @foo.dos.should == true
      @foo.tres.should == false
      @foo.quatro.should == true
    end

    it "should allow to query bits with question mark methods" do
      @foo.uno?.should == false
      @foo.dos?.should == true
      @foo.tres?.should == false
      @foo.quatro?.should == true
    end

    it "should allow to set bits directly" do
      @mobject.value = 0b1010
      @foo.uno = true
      @mobject.value.should == 0b1011

      @mobject.value = 0b1010
      @foo.dos = 1
      @mobject.value.should == 0b1010

      @mobject.value = 0b1010
      @foo.tres = 'YES'
      @mobject.value.should == 0b1110
    end

    it "should allow to reset bits directly" do
      @mobject.value = 0b1010
      @foo.uno = false
      @mobject.value.should == 0b1010

      @mobject.value = 0b1010
      @foo.dos = 'N'
      @mobject.value.should == 0b1000

      @mobject.value = 0b1010
      @foo.quatro = 0
      @mobject.value.should == 0b0010
    end
  end
end
