class EventCode < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :company
  has_many :image_files
  has_many :shipment_files
  
  acts_as_list scope: :company
  
  
  validates :name, presence: true
  validates_uniqueness_of :name, case_sensitive: false, scope: :company_id
  
  ############################
  #     Instance Methods     #
  ############################
  
  def gross_event_code?
    name == 'Gross'
  end
  
  def tare_event_code?
    name == 'Tare'
  end
  
  def signature_event_code?
    name == 'Signature'
  end
  
  #############################
  #     Class Methods         #
  #############################
  
end
