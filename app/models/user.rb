# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  dob                    :date
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  gender                 :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many  :snapshots, class_name: "Snapshot", foreign_key: "user_id", dependent: :destroy
  validates :gender, inclusion: { in: ['male', 'female'], allow_nil: true }
  validates :dob, presence: true
end
