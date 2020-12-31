require './spec/spec_helper'

class PrimaryModel
  include SparkApi::Primary
  attr_accessor :Primary, :id, :attributes
  def initialize(id, prime = false)
    @id = id
    @Primary = prime
    @attributes = {"Primary" => prime }
  end
end

describe SparkApi::PrimaryArray do
  it "should give me the primary element" do
    a = PrimaryModel.new(1)
    b = PrimaryModel.new(2)
    c = PrimaryModel.new(3)
    d = PrimaryModel.new(4, true)
    e = PrimaryModel.new(5)
    tester = subject.class.new([d,e])
    expect(tester.primary).to eq(d)
    tester = subject.class.new([a,b,c,d,e])
    expect(tester.primary).to eq(d)
    # Note, it doesn't care if there is more than one primary, just returns first in the list.
    b.Primary = true
    expect(tester.primary).to eq(b)
  end
  it "should return nil when there is no primary element" do
    a = PrimaryModel.new(1)
    b = PrimaryModel.new(2)
    c = PrimaryModel.new(3)
    d = PrimaryModel.new(4)
    e = PrimaryModel.new(5)
    tester = subject.class.new([])
    expect(tester.primary).to be(nil)
    tester = subject.class.new([a,b,c,d,e])
    expect(tester.primary).to be(nil)
  end
end


