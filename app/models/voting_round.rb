=begin
Copyright 2013 WBEZ
This file is part of Curious City.

Curious City is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

Curious City is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with Curious City.  If not, see <http://www.gnu.org/licenses/>.
=end
class VotingRound < ActiveRecord::Base
  has_many :voting_round_questions
  has_many :questions, through: :voting_round_questions, autosave: true

  after_save :add_default_public_label_if_empty
  after_save :add_default_private_label_if_empty
  before_update :update_winning_question_status
  before_update :change_current_voting_round_status
  validates :public_label, uniqueness: { case_sensitive: false }
  validates :private_label, uniqueness: { case_sensitive: false }

  module Status
    New = "New"
    Live = "Live"
    Completed = "Completed"
    Deactivated = "Deactivated"
    All = [New, Live, Completed, Deactivated]
  end

  def add_question(question)
    self.questions.push(question)
  end

  def previous
    VotingRound.where('status = ? and start_time < ?',"Completed", self.start_time).order(start_time: :desc).first
  end

  def next
    VotingRound.where('(status = ? or status = ?) and start_time > ?', "Live", "Completed", self.start_time).order(start_time: :asc).first
  end

  def winner
    return [] if voting_round_questions.empty?
    max_votes = voting_round_questions.maximum('vote_number')
    winning_vr_questions = voting_round_questions.select{ |vr_question| vr_question.vote_number == max_votes }
    winners = winning_vr_questions.map{ |vr_question| vr_question.question }
  end

  def vote_percentage(question)
    voting_round_question = voting_round_questions.select{ |vr_question| vr_question.question_id == question.id }[0]
    votes = voting_round_question.vote_number
    total_votes = voting_round_questions.map(&:vote_number).inject(0, :+)
    return total_votes==0 ? 0 : ((votes * 100.0)/total_votes).round
  end

  private

  def change_current_voting_round_status
    if self.status == VotingRound::Status::Live
      old_voting_round = VotingRound.where("status = ? AND id != ?", VotingRound::Status::Live, self.id ).first
      old_voting_round.update!({:status => VotingRound::Status::Completed}) unless old_voting_round.nil?
    end
  end

  def add_default_public_label_if_empty
    self.update_attributes(public_label: "Voting Round #{self.id}") if self.public_label.to_s == ''
  end

  def add_default_private_label_if_empty
    self.update_attributes(private_label: "Voting Round #{self.id}") if self.private_label.to_s == ''
  end

  def update_winning_question_status
    if self.status == VotingRound::Status::Completed && self.status_was == VotingRound::Status::Live
      self.winner.each { |question| question.update(status: Question::Status::Investigating) }
    end
  end
end
