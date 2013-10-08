require 'spec_helper'

describe Admin::VotingRoundsController do
  let(:valid_attributes) { { "start_time" => "2013-10-03 11:03:52" } }
  let(:valid_session) { {} }

  describe "GET index" do
    it "assigns all voting_rounds as @voting_rounds" do
      voting_round = VotingRound.create! valid_attributes
      get :index, {}, valid_session
      assigns(:voting_rounds).should eq([voting_round])
    end
  end

  describe "GET show" do
    it "assigns the requested voting_round as @voting_round" do
      voting_round = VotingRound.create! valid_attributes
      get :show, {:id => voting_round.to_param}, valid_session
      assigns(:voting_round).should eq(voting_round)
    end
  end

  describe "GET new" do
    it "assigns a new voting_round as @voting_round" do
      get :new, {}, valid_session
      assigns(:voting_round).should be_a_new(VotingRound)
    end
  end

  describe "GET edit" do
    it "assigns the requested voting_round as @voting_round" do
      voting_round = VotingRound.create! valid_attributes
      get :edit, {:id => voting_round.to_param}, valid_session
      assigns(:voting_round).should eq(voting_round)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new VotingRound" do
        expect {
          post :create, {:voting_round => valid_attributes}, valid_session
        }.to change(VotingRound, :count).by(1)
      end

      it "assigns a newly created voting_round as @voting_round" do
        post :create, {:voting_round => valid_attributes}, valid_session
        assigns(:voting_round).should be_a(VotingRound)
        assigns(:voting_round).should be_persisted
      end

      it "redirects to the voting round index url" do
        post :create, {:voting_round => valid_attributes}, valid_session
        response.should redirect_to(admin_voting_rounds_url)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved voting_round as @voting_round" do
        # Trigger the behavior that occurs when invalid params are submitted
        VotingRound.any_instance.stub(:save).and_return(false)
        post :create, {:voting_round => { "start_time" => "invalid value" }}, valid_session
        assigns(:voting_round).should be_a_new(VotingRound)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        VotingRound.any_instance.stub(:save).and_return(false)
        post :create, {:voting_round => { "start_time" => "invalid value" }}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested voting_round" do
        voting_round = VotingRound.create! valid_attributes
        # Assuming there are no other voting_rounds in the database, this
        # specifies that the VotingRound created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        VotingRound.any_instance.should_receive(:update).with({ "start_time" => "2013-10-03 11:03:52" })
        put :update, {:id => voting_round.to_param, :voting_round => { "start_time" => "2013-10-03 11:03:52" }}, valid_session
      end

      it "assigns the requested voting_round as @voting_round" do
        voting_round = VotingRound.create! valid_attributes
        put :update, {:id => voting_round.to_param, :voting_round => valid_attributes}, valid_session
        assigns(:voting_round).should eq(voting_round)
      end

      it "redirects to the voting_round" do
        voting_round = VotingRound.create! valid_attributes
        put :update, {:id => voting_round.to_param, :voting_round => valid_attributes}, valid_session
        response.should redirect_to(admin_voting_rounds_url)
      end
    end

    describe "with invalid params" do
      it "assigns the voting_round as @voting_round" do
        voting_round = VotingRound.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        VotingRound.any_instance.stub(:save).and_return(false)
        put :update, {:id => voting_round.to_param, :voting_round => { "start_time" => "invalid value" }}, valid_session
        assigns(:voting_round).should eq(voting_round)
      end

      it "re-renders the 'edit' template" do
        voting_round = VotingRound.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        VotingRound.any_instance.stub(:save).and_return(false)
        put :update, {:id => voting_round.to_param, :voting_round => { "start_time" => "invalid value" }}, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested voting_round" do
      voting_round = VotingRound.create! valid_attributes
      expect {
        delete :destroy, {:id => voting_round.to_param}, valid_session
      }.to change(VotingRound, :count).by(-1)
    end

    it "redirects to the voting_rounds list" do
      voting_round = VotingRound.create! valid_attributes
      delete :destroy, {:id => voting_round.to_param}, valid_session
      response.should redirect_to(admin_voting_rounds_url)
    end
  end

  describe "add question to voting round" do
    it "saves the voting round question" do
      voting_round = VotingRound.create! valid_attributes
      question = FactoryGirl.create(:question)
      expect {
        put :add_question, {:question_id => question.id, :id => voting_round.id}
      }.to change(VotingRoundQuestion, :count).by(1)
    end
  end
end