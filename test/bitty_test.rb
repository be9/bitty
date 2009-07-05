require 'test_helper'
require 'support/models'
load 'support/schema.rb'

class Foo < ActiveRecord::Base
  bitty :bitval, :uno, :dos, :tres, :quatro
end

class BittyTest < Test::Unit::TestCase
  context "Foo" do
    before { @foo = Foo.new }

    it "should have :bitval attribute" do
      @foo.should respond_to :bitval
      @foo.should respond_to :bitval=
    end

    it "attribute method should return an instance of BitProxy" do
      @foo.bitval.should be_kind_of(Bitty::BitProxy)
    end

    it "proxy value should correspond to model object column value" do
      @foo2 = Foo.new
      [0, 1, 200].each do |ival|
        @foo[:bitval] = ival
        @foo.bitval.send(:value).should == ival
        @foo2.bitval.send(:value).should be_nil
      end
    end

    it "proxy :value= should set model object's value" do
      [0, 1, 200].each do |ival|
        @foo.bitval.send(:value=, ival)
        @foo[:bitval].should == ival
      end
    end

    it "proxy :value= should not spoil other objects of the same type" do
      @foo2 = Foo.new
      @foo2.bitval.send(:value=, 333)
      @foo.bitval.send(:value=, 1000)
      @foo2.bitval.value.should == 333
    end
  end
end

class FooWithScope < Foo
  bitty_named_scope :with_uno, :bitval, :uno
  bitty_named_scope :without_4, :bitval, :quatro => 0
  bitty_named_scope :with_110_, :bitval, :quatro => 1, :tres => 1, :dos => 0
end

class BittyNamedScopeTest < Test::Unit::TestCase
  before :all do
    @foos = (0..15).to_a.map do |v|
      FooWithScope.create!(:bitval => v)
    end
  end

  it ".with_uno should find values with :uno set" do
    FooWithScope.with_uno.all.should == fs(1,3,5,7,9,11,13,15)
  end

  it ".with_4 should find values with :quatro unset" do
    FooWithScope.without_4.all.should == fs(*(0..7).to_a)
  end

  it ".with_110_ should find by bit prefix 110" do
    FooWithScope.with_110_.all.should == fs(12,13)
  end

  it "raises ArgumentError given invalid bitfield" do
    lambda do
      FooWithScope.class_eval do
        bitty_named_scope :test_1, :nonexistent, :foo
      end
    end.should raise_error(ArgumentError)
  end

  it "raises ArgumentError given invalid bitname" do
    lambda do
      FooWithScope.class_eval do
        bitty_named_scope :test_2, :bitval, :foo
      end
    end.should raise_error(ArgumentError)
  end

  def fs(*args)
    args.map { |i| @foos[i] }
  end
end
