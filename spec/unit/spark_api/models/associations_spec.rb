require 'spec_helper'

class ToolBox < Base
  include Concerns::Savable,
  Concerns::Destroyable

  self.element_name="toolboxes"

  def initialize(attributes={})
    has_many :hammers, :subresource_class => Hammer
    has_many :nails, :subresource_class => Nail

    super(attributes)
  end
  def resource_pluralized
      "ToolBoxes"
    end
end

class Hammer < Base
  include Concerns::Savable,
  Concerns::Destroyable
  self.element_name="hammers"
end

class Nail < Base
  include Concerns::Savable,
  Concerns::Destroyable
  self.element_name="nails"
end

describe ToolBox do

  before :each do
    stub_auth_request
  end

  it "can have associated resources of different types" do
    toolbox = ToolBox.new
    toolbox.hammers.should be_an(Array)
    toolbox.nails.should be_an(Array)
    toolbox.hammers.count.should be 0
    toolbox.nails.count.should be 0

    toolbox.hammers << Hammer.new({:Name => "Hammer 1"})
    toolbox.hammers << Hammer.new({:Name => "Hammer 2"})
    toolbox.nails << Nail.new({:Name => "N 1"})

    toolbox.hammers.count.should be 2
    toolbox.nails.count.should be 1
  end

  it "ignores any associated resources changes unless the associated_resource_will_change! method is invoked" do
    toolbox = ToolBox.new
    toolbox.hammers << Hammer.new({:Name => "Hammer 1"})
    toolbox.hammers << Hammer.new({:Name => "Hammer 2"})
    toolbox.nails << Nail.new({:Name => "N 1"})

    toolbox.changed_associated_objects.count.should be 0

    toolbox.nails_will_change!
    toolbox.changed_associated_objects.count.should be 1

    toolbox.hammers_will_change!
    toolbox.changed_associated_objects.count.should be 3
  end

  it "ignores any associated resources that have been deleted/destroyed" do
    toolbox = ToolBox.new
    toolbox.hammers_will_change!

    toolbox.hammers << Hammer.new({:Name => "Hammer 1"})
    toolbox.hammers << Hammer.new({:Name => "Hammer 2"})
    toolbox.changed_associated_objects.count.should be 2

    toolbox.hammers.first.destroy
    toolbox.changed_associated_objects.count.should be 1
  end


  context "when it is saved" do
    it "should be persisted along with all it's associated resources" do
      stub_api_post("/toolboxes",  {"ToolBoxes" => [{}]}, "base.json")
      stub_api_get("/toolboxes/1/hammers", "base.json")
      stub_api_post("/toolboxes/1/hammers",  {"Hammers" => [{"Name" => "Hammer 1"},{"Name" => "Hammer 2"}]})

      toolbox = ToolBox.new
      toolbox.hammers_will_change!
      toolbox.hammers << Hammer.new({:Name => "Hammer 1"})
      toolbox.hammers << Hammer.new({:Name => "Hammer 2"})
      toolbox.save

      toolbox.persisted?.should be_true
      toolbox.hammers.each {|h| h.persisted?.should be_true}

      toolbox.changed_associated_objects.count.should be 0

    end

    it "makes a copy of an associated resource if that resource was already persisted under a different URI" do
      pending
    end

  end



end


