require './spec/spec_helper'

describe Notification do
  before(:each) do
    stub_auth_request
  end

  subject do
    m = Notification.new
    m.attributes['Type'] = 'OperationComplete'
    m.attributes['Message'] = 'Your PDF generation has completed!'
    m.attributes['BrowserUri'] = 'http://myapplication.com/cmas/19581825.pdf'
    m.attributes['ResourceUri'] = 'http://myapplication.com/cmas/19581825.json'
    m
  end

  context "/notifications", :support do
    on_get_it "should get my notifications" do
      stub_api_get('/notifications', 'notifications/notifications.json')

      notifications = Notification.get
      notifications.should be_an(Array)
      notifications.count.should equal(3)
    end

    on_post_it "should create a new notification" do
      stub_api_post("/notifications", 'notifications/new.json', 'notifications/post.json')
      subject.save.should be(true)
    end

    on_post_it "should fail saving" do
      stub_api_post("/notifications", 'notifications/new_empty.json') do |request|
        request.to_return(:status => 400, :body => fixture('errors/failure.json'))
      end
      m = subject.class.new
      m.attributes['Message'] = 'Your PDF generation has completed!'
      m.attributes['BrowserUri'] = 'http://myapplication.com/cmas/19581825.pdf'
      m.attributes['ResourceUri'] = 'http://myapplication.com/cmas/19581825.json'
      m.save.should be(false)
      expect{ m.save! }.to raise_error(SparkApi::ClientError){ |e| e.status.should == 400 }
    end
  end

  context "/notifications/<notification_id1>,<notification_id2>,...<notification_idN>", :support do
    on_put_it "should mark notifications as read" do
      to_mark = [12345678901234567890000001,12345678901234567890000002]
      stub_api_put("/notifications/#{to_mark.join(',')}",
                   'notifications/mark_read.json', 'success.json')

      Notification.mark_read(to_mark)
    end
  end

  context "/notifications/unread", :support do
    on_get_it "should get a count of unread notifications" do
      stub_api_get('/notifications/unread', 'notifications/unread.json', {:_pagination => 'count'})

      notification_count = Notification.unread
      notification_count.should equal(30)
    end
  end
end
