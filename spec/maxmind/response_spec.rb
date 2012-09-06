# -*- coding: utf-8 -*-

require 'spec_helper'

REQUIRED_FIELDS =

RECOMMENDED_FIELDS =

OPTIONAL_FIELDS =

describe Maxmind::Response do
  before do
    Maxmind.license_key = 'LICENSE_KEY'

    required_fields = JSON.parse(load_fixture("required_fields.json"))
    recommended_fields = JSON.parse(load_fixture("recommended_fields.json"))
    optional_fields = JSON.parse(load_fixture("optional_fields.json"))
    all_fields = required_fields.merge(recommended_fields).merge(optional_fields)

    @request = Maxmind::Request.new(all_fields)
    stub_request(:post, "https://minfraud2.maxmind.com/app/ccv2r").
      to_return(:body => load_fixture("response.txt"), :status => 200)
    @response = @request.process!
  end

  it "requires a response" do
    expect { Maxmind::Response.new }.to raise_exception(ArgumentError)
  end

  it "exposes its attributes" do
    @response.attributes.should be_a Hash
  end

  it "has a distance" do
    @response.distance.should == 329
  end

  it "has a maxmind ID" do
    @response.maxmind_id.should == '9VSOSDE2'
  end

  it "has a risk score" do
    @response.risk_score.should == 2.0
  end

  it "has a score" do
    @response.score.should == 7.66
  end

  it "has queries remaining" do
    @response.queries_remaining.should == 955
  end

  it "has an explanation" do
    @response.explanation.should_not == nil
  end

  it "converts Latin1 encoding to UTF8" do
    # Maxmind responds with ISO-8859-1 encoded data
    stub_request(:post, "https://minfraud2.maxmind.com/app/ccv2r").
      to_return(
        :body => load_fixture("latin1_response.txt").force_encoding("ISO-8859-1"),
        :status => 200
      )
    latin_response = @request.process!
    latin_response.ip_city.should == "Nürnberg"
  end
end