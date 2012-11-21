require 'spec_helper'

describe Template do

  before(:each) { stub_auth_request }

  context "/templates" do

    it "should get my templates" do
      s = stub_api_get("/templates", "templates/get.json")
      templates = Template.get
      templates.should be_an(Array)
      s.should have_been_requested
    end

    it "should create a new template" do
      s = stub_api_post("/templates", "templates/new.json", "templates/post.json")
      template = Template.new({
        :Name => "Template",
        :Subject => "This is a subject",
        :Body => "This is a body."
      })
      template.save
      s.should have_been_requested
    end

  end

  context "/templates/<id>" do

    let(:id) { "20101230223226074204000000" }

    subject do
      stub_api_get("/templates/#{id}", "templates/get.json")
      template = Template.find(id)
      template.should be_a(Template)
      template.Id.should eq(id)
      template
    end

    it "should update an existing template" do
      s = stub_api_put("/templates/#{id}", {:Name => "This is a new name"}, "success.json")
      subject.Name = "This is a new name"
      subject.save
      s.should have_been_requested
    end

    it "should destroy a template" do
      s = stub_api_delete("/templates/#{id}", "success.json")
      subject.destroy
      s.should have_been_requested
    end

  end

end
