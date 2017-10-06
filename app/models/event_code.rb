class EventCode < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :company
  has_many :image_files
  has_many :shipment_files
  
  
  validates :name, presence: true
  
end
