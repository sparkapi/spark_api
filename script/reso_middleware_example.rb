#!/usr/bin/env ruby

# This script demonstrates how to access the RESO Web API with FBS's Ruby API client.

require "spark_api"
require "nokogiri"

# set up session and RESO Web API middleware
SparkApi.configure do |config|
    config.authentication_mode = SparkApi::Authentication::OAuth2
    config.middleware = :reso_api
end
  #### COPY/PASTE YOUR ACCESS TOKEN BELOW
SparkApi.client.session = SparkApi::Authentication::OAuthSession.new({ :access_token => "your_access_token_here" })

# pull metadata from RESO Web API
metadata_res = SparkApi.client.get("/$metadata")
metadata_xml = Nokogiri::XML(metadata_res).remove_namespaces!

## make an array of fields which need to be checked for readable values
## API now returns decoded field values. This is no longer necessary
#fields_to_lookup = []
#metadata_xml.xpath('//Schema/EnumType/@Name').each do |el|
#  fields_to_lookup << el.to_str
#end

# get 25 listings
listings = SparkApi.client.get("/Property", {:$top => 25 })
puts listings

## API now returns decoded field values. The code below is no longer needed
#listings['value'].each do |listing| # for each listing,
#  fields_to_lookup.each do |field| # go through the array of fields to be checked.
#    if !!listing[field] # when one of the fields that needs to be checked exists in a listing,
#      if listing[field].is_a? String
#        readable = metadata_xml.xpath( # check for readable value to be swapped in
#          "//Schema/
#          EnumType[@Name=\"#{field}\"]/
#          Member[@Name=\"#{listing[field]}\"]/
#          Annotation"
#        ).attr("String")
#
#        # if there is a readable value, swap it in
#        if !!readable
#          listing[field] = readable.to_str
#        end
#
#      elsif listing[field].is_a? Array
#        readable_arr = []
#        listing[field].each do |el|
#          readable = metadata_xml.xpath( # check for readable value to be swapped in
#            "//Schema/
#            EnumType[@Name=\"#{field}\"]/
#            Member[@Name=\"#{el}\"]/
#            Annotation"
#          ).attr("String")
#
#          # assemble a new array with readable values and swap it in
#          if !!readable
#            readable_arr << readable.to_str
#          else
#            readable_arr << el
#          end
#          listing[field] = readable_arr
#        end
#      end
#    end
#  end
#end
#
#puts listings
