=begin
Copyright 2013 WBEZ
This file is part of Curious City.

Curious City is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

Curious City is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with Curious City.  If not, see <http://www.gnu.org/licenses/>.
=end
class Question < ActiveRecord::Base
  ANONYMOUS = "Anonymous"

  acts_as_taggable
  has_many :voting_rounds, through: :voting_round_questions
  has_many :voting_round_questions
  has_many :answers, autosave: true
  has_many :completed_answers, -> { where type: Answer::Type::Answer }, class_name: 'Answer'
  has_many :updates, -> { where type: Answer::Type::Update }, class_name: 'Answer'
  has_and_belongs_to_many :categories, -> { readonly }, join_table: :questions_categories
  accepts_nested_attributes_for :answers
  before_update :set_tags_updated_at_if_tags_changed
  before_update :set_notes_updated_at_if_notes_changed
  attr_readonly :original_text
  attr_accessor :email_confirmation
  before_create :copy_display_text_into_original_text
  validates :display_text, length: { maximum: 2000, minimum: 1}
  validates :neighbourhood, length: { maximum: 100 }
  validates :name, length: {in: 1..255 }, format: { with: /\A[a-zA-Z\s\.\-'@]+\z/, message: "only allows letters, spaces, periods, hyphens, apostrophes, and @ signs" }
  validates :email, length: {maximum: 255}, confirmation: {unless: "email.empty?"}, email: true
  validates :email_confirmation, presence: true, on: :create,  unless: "email.empty?"

  def self.with_status_and_category(status, category_name)
    if category_name.present?
      includes(:categories).where(categories: {name: category_name}, status: status).order(created_at: :desc)
    else
      where(status: status).order(created_at: :desc)
    end
  end

  def self.with_search_text(search_text, category_id = nil)
    searched_fields = %w{display_text original_text description neighbourhood notes questions.name}
    search_query= searched_fields.map{|v| "#{v} like :text"}.join(" or ")

    if category_id.present?
      includes(:categories).where(search_query, text: "%"+search_text.to_s+"%").references(:categories).where("category_id = ?", category_id.to_s)
    else
      includes(:categories).where(search_query, text: "%"+search_text.to_s+"%").references(:categories)
    end
   end

 module Status
   New = "New"
   Answered = "Answered"
   Investigating = "Investigating"
   Removed = "Removed"
   All = [New, Answered, Investigating, Removed]
 end

  def active?
    status != Question::Status::Removed
  end

  def answered?
    status == Question::Status::Answered
  end

  def investigating?
    status == Question::Status::Investigating
  end

  def display_author
    anonymous ? ANONYMOUS : name
  end

  def in_active_voting_rounds?
    ([VotingRound::Status::New, VotingRound::Status::Live] & self.voting_rounds.map(&:status)).any?
  end

  def previous_question
    Question.where('status != ? AND id<?', "Removed", self.id).order(id: :desc).first
  end

  def next_question
    Question.where('status != ? AND id>?', "Removed", self.id).order(id: :asc).first
  end

  def self.recent_questions
    order(updated_at: :desc).limit(10)
  end

  def self.recent_questions_with_updated_tags
    order(tags_updated_at: :desc).where('tags_updated_at IS NOT NULL').limit(10)
  end

  def self.recent_questions_with_updated_notes
    order(notes_updated_at: :desc).where('notes_updated_at IS NOT NULL').limit(10)
  end

  private

  def set_tags_updated_at_if_tags_changed
    self.tags_updated_at =  Time.zone.now if self.tag_list_changed?
  end

  def set_notes_updated_at_if_notes_changed
    self.notes_updated_at = Time.zone.now if self.notes_changed?
 end

  def copy_display_text_into_original_text
    self.original_text = self.display_text unless self.original_text.present?
  end
end
