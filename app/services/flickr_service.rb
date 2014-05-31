=begin
Copyright 2013 WBEZ
This file is part of Curious City.

Curious City is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

Curious City is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with Curious City.  If not, see <http://www.gnu.org/licenses/>.
=end
require 'flickrie'

class FlickrService
  def get_api_key
    # To allow this to be easily used in Heroku, without committing it to git.
    # The previous 'some key' convention is kept. There is no particular reason for this.
    ENV.fetch('FLICKR_API_KEY', 'some key');
  end

  def get_shared_secret
    ENV.fetch('FLICKR_SHARED_SECRET', 'shhh, its secret')
  end

  def find_pictures(search_string)
    Flickrie.api_key = get_api_key
    Flickrie.shared_secret = get_shared_secret
    query = {:text => search_string, :license=>"1,2,3,4,5,6", :extras=>['owner_name'], :per_page=>50}
    Flickrie.search_photos(query).map{|photo| FlickrPicture.new(photo)}
  end
end
