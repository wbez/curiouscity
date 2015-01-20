=begin
Copyright 2013 WBEZ
This file is part of Curious City.

Curious City is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

Curious City is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with Curious City.  If not, see <http://www.gnu.org/licenses/>.
=end
require 'spec_helper'

describe 'FlickrPicture' do
  before do
    @photo = double(Flickr::Object::Photo,
                   farm: 4,
                   server: "1234",
                   id: "1234567890",
                   secret: "abcd1234",
                   width: 100,
                   height: 200,
                   owner: double(:owner, username: "owner"),
                   url: "attribution_url")
    @picture = FlickrPicture.new(@photo)
  end

  it "sets the attributes" do
    @picture.farm.should == @photo.farm
    @picture.server.should == @photo.server
    @picture.picture_id.should == @photo.id
    @picture.secret_key.should == @photo.secret
    @picture.width.should == @photo.width
    @picture.height.should == @photo.height
    @picture.owner.should == @photo.owner.username
    @picture.attribution_url.should == @photo.url
  end

  describe "url" do
    it "sets the right url from multiple fields" do
      @picture.url.should == "http://farm4.staticflickr.com/1234/1234567890_abcd1234.jpg"
    end
  end
end
