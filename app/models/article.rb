# == Schema Information
#
# Table name: articles
#
#  id            :integer          not null, primary key
#  archived      :boolean          default(FALSE), not null
#  content       :text
#  public        :boolean          default(TRUE), not null
#  reports_count :integer          default(0), not null
#  title         :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  user_id       :integer          not null
#
# Indexes
#
#  index_articles_on_user_id  (user_id)
#
# Foreign Keys
#
#  user_id  (user_id => users.id)
#
class Article < ApplicationRecord
  belongs_to :user
  has_one_attached :image

  validates :title, presence: true
  validates :content, presence: true

  before_save :archive_if_reported_often

  private

  def archive_if_reported_often
    if reports_count >= 3
      self.archived = true
    end
  end
end
