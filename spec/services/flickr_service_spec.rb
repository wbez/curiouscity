=begin
Copyright 2013 WBEZ
This file is part of Curious City.

Curious City is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

Curious City is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with Curious City.  If not, see <http://www.gnu.org/licenses/>.
=end
require 'spec_helper'

describe FlickrService do
  let(:flickr_service) { FlickrService.new }

  it "get API key" do
    File.stub(:exists?).and_return(true)
    YAML.stub(:load_file).and_return({"key"=>"mock_key"})
    flickr_service.get_api_key.should eq "mock_key"
  end

  it "find_pictures" do
    File.stub(:exists?).and_return(true)
    YAML.stub(:load_file).and_return({"key"=>"mock_key"})
    photo = double(Flickr::Object::Photo)
    Flickr.stub_chain(:photos, :search).and_return([photo])
    FlickrPicture.stub(:new).with(photo).and_return("some photo")
    flickr_service.find_pictures("chicago").should eq ["some photo"]
  end
end
