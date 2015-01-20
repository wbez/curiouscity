=begin
Copyright 2013 WBEZ
This file is part of Curious City.

Curious City is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

Curious City is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with Curious City.  If not, see <http://www.gnu.org/licenses/>.
=end
require 'features/features_spec_helper'

describe "widgets" do
  before do
    @voting_round = FactoryGirl.create(:voting_round, status: VotingRound::Status::Live)
  end
  describe 'visit voting widget page' do
    before do
      @questions = [FactoryGirl.create(:question), FactoryGirl.create(:question, display_text: "another text"), FactoryGirl.create(:question, display_text: "third text"), FactoryGirl.create(:question, display_text: "fourth text")]
      @voting_round.questions = @questions
      VotingRoundQuestion.where(question_id: @questions[0].id).first.update_attributes(vote_number: 10)
      VotingRoundQuestion.where(question_id: @questions[1].id).first.update_attributes(vote_number: 0)
      VotingRoundQuestion.where(question_id: @questions[2].id).first.update_attributes(vote_number: 5)
      Array.any_instance.stub(:shuffle).and_return(@questions[0..2])
      @vote_widget = VoteWidget.new
      @vote_widget.load
    end

    context "before voting" do
      it "has questions from active voting round" do
        @vote_widget.questions[0].should have_text @questions.first.display_text
        @vote_widget.questions[1].should have_text @questions.second.display_text
        @vote_widget.widget_prompt.should have_text "WHICH QUESTION SHOULD WBEZ INVESTIGATE NEXT?"
        @vote_widget.questions[0].should have_link('vote' + @questions.first.id.to_s)
        @vote_widget.questions[1].should have_link('vote' + @questions.second.id.to_s)
      end

      it "only shows three questions" do
        expect(@vote_widget.questions.size).to eq 3
      end
    end

    context "after voting" do

      before do
        @vote_widget.vote_buttons[0].click
      end

      describe "shows voting results" do
        it "hides vote buttons, shows ranks, thanks user, and orders questions by voting number" do
          @vote_widget.should_not have_vote_buttons
          @vote_widget.widget_prompt.should have_text "THANKS FOR VOTING!"

          @vote_widget.questions[0].should have_text "1st"
          @vote_widget.questions[1].should have_text "2nd"
          @vote_widget.questions[2].should have_text "3rd"

          @vote_widget.questions[0].should have_text @questions[0].display_text
          @vote_widget.questions[1].should have_text @questions[2].display_text
          @vote_widget.questions[2].should have_text @questions[1].display_text
        end
      end
    end
  end
  describe "visit ask widget page" do
    before do
      @ask_widget = AskWidget.new
      @ask_widget.load
    end

    it "allows user to submit a question", js: true do
     @ask_widget.submit_question_text.set("What should this question be?")
      @ask_widget.submit_button.click
      switch_to_popup
      @home = Home.new
      @home.should be_displayed
      @home.ask_question_modal.question_display_text.text.should == "What should this question be?"
    end

    it "allows user to browse answers and questions" do
      @ask_widget.answers_link[:href].should == filter_questions_url(status: "answered")
      @ask_widget.questions_link[:href].should == filter_questions_url(status: "archive")
    end
  end
end
