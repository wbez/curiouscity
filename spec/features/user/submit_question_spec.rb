=begin
Copyright 2013 WBEZ
This file is part of Curious City.

Curious City is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

Curious City is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with Curious City.  If not, see <http://www.gnu.org/licenses/>.
=end
require 'features/features_spec_helper'

describe 'Ask a question', js: true do

  before(:each) do
    @mock_pictures=[double(Flickr::Object::Photo), double(Flickr::Object::Photo)]
    @mock_pictures[0].stub(:id).and_return("10542729043")
    @mock_pictures[0].stub(:secret).and_return("af2c52cac9")
    @mock_pictures[0].stub(:farm).and_return(4)
    @mock_pictures[0].stub(:server).and_return("5477")
    @mock_pictures[0].stub(:width).and_return(1)
    @mock_pictures[0].stub(:height).and_return(2)
    @mock_pictures[0].stub_chain(:owner, :username).and_return("owner")
    @mock_pictures[0].stub(:url).and_return("url1")
    @mock_pictures[1].stub(:id).and_return("10542729043")
    @mock_pictures[1].stub(:secret).and_return("af2c52cac9")
    @mock_pictures[1].stub(:farm).and_return(4)
    @mock_pictures[1].stub(:server).and_return("5477")
    @mock_pictures[1].stub(:width).and_return(1)
    @mock_pictures[1].stub(:height).and_return(2)
    @mock_pictures[1].stub_chain(:owner, :username).and_return("owner")
    @mock_pictures[1].stub(:url).and_return("url2")
    @mock_flickr_service = double(FlickrService)
    @pictures = @mock_pictures.map{|p| FlickrPicture.new(p)}
    @mock_flickr_service.stub(:find_pictures).and_return(@pictures)
    FlickrService.stub(:new).and_return(@mock_flickr_service)
  end

  def setup_ask_question_modal
    @home = Home.new
    @home.load
    @home.wait_for_display_text
    @home.display_text.set "Why is the sky blue?"
    @home.ask_button.click
    @ask_question_modal = @home.ask_question_modal
    @home.wait_for_ask_question_modal
  end

  def setup_question_picture_modal
    @ask_question_modal.wait_until_question_display_text_visible
    @ask_question_modal.question_display_text.click
    @ask_question_modal.question_display_text.set("Why is the sky green?")
    @ask_question_modal.question_description.click
    @ask_question_modal.question_description.set("I don't know it seems green to me")
    @ask_question_modal.wait_for_question_name
    @ask_question_modal.question_name.click
    @ask_question_modal.question_name.set("Robert Johnson")
    @ask_question_modal.question_anonymous.click
    @ask_question_modal.question_email.set("rjohnson@a.com")
    @ask_question_modal.question_email_confirmation.set("rjohnson@a.com")
    @ask_question_modal.question_neighbourhood.set("Bucktown")
    @ask_question_modal.question_categories[0].click
    @ask_question_modal.question_categories[1].click
    @ask_question_modal.modal_form_next.click
    @home.wait_for_question_picture_modal
    @question_picture_modal = @home.question_picture_modal
  end

  def setup_confirm_question_modal
    @question_picture_modal.search_field.set("chicago")
    @question_picture_modal.search_button.click
    @question_picture_modal.wait_for_thumbnails
    @question_picture_modal.thumbnails[0].click
    @question_picture_modal.next_button.click
    @home.wait_for_confirm_question_modal
    @confirm_question_modal = @home.confirm_question_modal
  end

  describe "new question modal" do
    before do
      setup_ask_question_modal
    end
    it "has title, prepopulated question, and progress indication" do
      @ask_question_modal.title.text.should == "Submit your question to Curious City"
      @ask_question_modal.question_display_text.text.should == "Why is the sky blue?"
      @ask_question_modal.footer.should have_content "Step 1/3"
    end

    it "has a pop up modal when the link is clicked" do
        @ask_question_modal.question_guideline_link.click
        @ask_question_modal.wait_for_popup
        @ask_question_modal.should have_popup
    end
  end

  it "is shown when root_path is visited with anchor '#ask'" do
    @home = Home.new
    @home.load(anchor: "ask")
    @home.ask_question_modal.title.text.should == "Submit your question to Curious City"
  end

  describe "flicker question modal" do
    before do
      @category1 = FactoryGirl.create(:category, :other)
      @category2 = FactoryGirl.create(:category, :other, label: "MyString2")
      setup_ask_question_modal
      setup_question_picture_modal
    end

    it "has picture question field and progress indication" do
      @question_picture_modal.should have_field('search-field')
      @question_picture_modal.footer.should have_content "Step 2/3"
      @question_picture_modal.next_button.click
    end

    it "shows pictures from flicker that can be selected one at a time" do
      @question_picture_modal.search_field.set("chicago")
      @question_picture_modal.search_button.click
      @question_picture_modal.wait_for_thumbnails
      @question_picture_modal.thumbnails[0][:class].should eq "thumbnail"
      @question_picture_modal.thumbnails[0].click
      @question_picture_modal.thumbnails[0][:class].should eq "thumbnail selected-thumbnail"
      @question_picture_modal.thumbnails[1].click
      @question_picture_modal.thumbnails[0][:class].should eq "thumbnail"
      @question_picture_modal.thumbnails[1][:class].should eq "thumbnail selected-thumbnail"
    end

    context "when back button is clicked" do
      it "shows ask question modal" do
        @question_picture_modal.modal_form_back.click
        @home.wait_for_ask_question_modal
        @home.should have_ask_question_modal
      end
    end
  end

  describe "confirm question modal" do
    before do
      @category1 = FactoryGirl.create(:category, :other)
      @category2 = FactoryGirl.create(:category, :other, label: "MyString2")
      setup_ask_question_modal
      setup_question_picture_modal
      setup_confirm_question_modal
    end

    it "has expected content" do
      @confirm_question_modal.title.should have_content "Double check that your question looks good"
      @confirm_question_modal.body.should have_content "Why is the sky green?"
      @confirm_question_modal.body.should have_content "I don't know it seems green to me"
      @confirm_question_modal.body.should have_content "Robert Johnson"
      @confirm_question_modal.body.should have_content "Name (not public)"
      @confirm_question_modal.body.should have_content "Email (not public)"
      @confirm_question_modal.body.should have_content "rjohnson@a.com"
      @confirm_question_modal.body.should have_content "Bucktown"
      @confirm_question_modal.body.should have_content @category1.label
      @confirm_question_modal.body.should have_content @category2.label
      picture = @mock_pictures[0]
      @confirm_question_modal.picture[:src].should eq "http://farm#{picture.farm}.staticflickr.com/#{picture.server}/#{picture.id}_#{picture.secret}.jpg"
      @confirm_question_modal.footer.should have_content("Step 3/3");
      @confirm_question_modal.modal_form_submit
    end

    context "when back button is clicked" do
      it "shows question picture modal" do
        @confirm_question_modal.modal_form_back.click
        @home.wait_for_question_picture_modal
        @home.should have_question_picture_modal
      end
    end
  end

  describe "question received modal" do
    it "has question received content" do
      @category1 = FactoryGirl.create(:category, :other)
      @category2 = FactoryGirl.create(:category, :other, label: "MyString2")
      setup_ask_question_modal
      setup_question_picture_modal
      setup_confirm_question_modal
      @confirm_question_modal.modal_form_submit.click
      @question_received_modal = @home.question_received_modal
      @question_received_modal.title.text.should == "Thanks for submitting your question!"
      @question_received_modal.archive_link.text.should == "new + unanswered archive" #todo: add link test.
      @question_received_modal.should have_link("public vote", href: root_path)
      @question_received_modal.should have_link("online", href: "http://www.wbez.org/series/curious-city")
      @question_received_modal.should have_link("WBEZ 91.5 FM", href: "http://www.wbez.org/player")
    end
  end

  describe "show question after submission" do
    it "has new question content in admin" do
      @category1 = FactoryGirl.create(:category, :other)
      @category2 = FactoryGirl.create(:category, :other, label: "MyString2")
      setup_ask_question_modal
      setup_question_picture_modal
      setup_confirm_question_modal
      @confirm_question_modal.modal_form_submit.click
      signin_as_admin
      @admin_show_question = Admin::ShowQuestion.new
      @admin_show_question.load(id: Question.last.id)
      @admin_show_question.body.should have_content "Why is the sky green?"
      @admin_show_question.body.should have_content "I don't know it seems green to me"
      @admin_show_question.body.should have_content "Robert Johnson"
      @admin_show_question.body.should have_content "rjohnson@a.com"
      @admin_show_question.body.should have_content "Bucktown"
      @admin_show_question.body.should have_content "true"
      @admin_show_question.body.should have_content @category1.label
      @admin_show_question.body.should have_content @category2.label
    end
  end
end
