class Article < ApplicationRecord
  # include PgSearch::Model

  # pg_search_scope :search_by_title_and_body, against: {
  #   title: 'A',
  #   body: 'B'
  # }, using: {
  #   tsearch: { prefix: true }
  # }
  validates :title, presence: true, length: { minimum: 5, maximum: 100 }
  validates :body, presence: true, length: { minimum: 10, maximum: 500 }
end
