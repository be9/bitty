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
