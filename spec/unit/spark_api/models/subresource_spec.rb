require './spec/spec_helper'

require 'time'

describe Subresource do
  let(:dummy_class) do
    Class.new do
      extend(Subresource)
    end
  end

  it "should handle times without tz offset" do
    times = {'Date' => '10/01/2012', 'StartTime' => '9:00 am', 'EndTime' => '12:00 pm'}
    start_time = Time.local(2012,10,1,9,0,0)
    end_time = Time.local(2012,10,1,12,0,0)
    date = Date.new(2012,10,1)

    dummy_class.parse_date_start_and_end_times(times)

    expect(times['Date']).to eq(date)

    if RUBY_VERSION < '1.9'
      expect(times['StartTime']).to eq(Time.parse(start_time.to_s))
      expect(times['EndTime']).to eq(Time.parse(end_time.to_s))
    else
      expect(times['StartTime']).to eq(start_time.to_time)
      expect(times['EndTime']).to eq(end_time.to_time)
    end
  end

  it "should handle times with tz offset" do
    times = {'Date' => '10/01/2012', 'StartTime' => '09:00-0700', 'EndTime' => '12:00-0700'}
    start_time = DateTime.new(2012,10,1,9,0,0,'-0700')
    end_time = DateTime.new(2012,10,1,12,0,0,'-0700')
    date = Date.new(2012,10,1)

    dummy_class.parse_date_start_and_end_times(times)

    expect(times['Date']).to eq(date)

    if RUBY_VERSION < '1.9'
      expect(times['StartTime']).to eq(Time.parse(start_time.to_s))
      expect(times['EndTime']).to eq(Time.parse(end_time.to_s))
    else
      expect(times['StartTime']).to eq(start_time.to_time)
      expect(times['EndTime']).to eq(end_time.to_time)
    end
  end

  it "should handle times with tz offset and seconds" do
    times = {'Date' => '10/01/2012', 'StartTime' => '09:12:34-0700', 'EndTime' => '12:43:21-0700'}
    start_time = DateTime.new(2012,10,1,9,12,34,'-0700')
    end_time = DateTime.new(2012,10,1,12,43,21,'-0700')
    date = Date.new(2012,10,1)

    dummy_class.parse_date_start_and_end_times(times)

    expect(times['Date']).to eq(date)

    if RUBY_VERSION < '1.9'
      expect(times['StartTime']).to eq(Time.parse(start_time.to_s))
      expect(times['EndTime']).to eq(Time.parse(end_time.to_s))
    else
      expect(times['StartTime']).to eq(start_time.to_time)
      expect(times['EndTime']).to eq(end_time.to_time)
    end
  end

  it "should raise an exception for unsupported formats" do
    times = {'Date' => '10/01/2012', 'StartTime' => '_9:00_ _am_', 'EndTime' => '_12:00_ _pm_'}

    expect {dummy_class.parse_date_start_and_end_times(times)}.to raise_error(ArgumentError)
  end

  it "should ignore an empty Date" do
    times = {'Date' => '', 'StartTime' => '09:12:34-0700', 'EndTime' => '12:43:21-0700'}
    dummy_class.parse_date_start_and_end_times(times)
    expect(times['Date']).to eq('')
  end

  it "should ignore an empty StartTime" do
    times = {'Date' => '10/01/2012', 'StartTime' => '', 'EndTime' => '12:43:21-0700'}
    dummy_class.parse_date_start_and_end_times(times)
    expect(times['StartTime']).to eq('')
  end

  it "should ignore an empty EndTime" do
    times = {'Date' => '10/01/2012', 'StartTime' => '09:12:34-0700', 'EndTime' => ''}
    dummy_class.parse_date_start_and_end_times(times)
    expect(times['EndTime']).to eq('')
  end
end
