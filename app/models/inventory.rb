class Inventory < ActiveRecord::Base
  
  serialize :closed_packs, Array
  serialize :scanned_packs, Array
  
  belongs_to :user
  belongs_to :company
  
  ############################
  #     Instance Methods     #
  ############################
  
  def remaining_packs
    closed_packs - scanned_packs
  end
  
  def distinct_pack_descriptions
    remaining_packs.map { |pack| [pack['PrintDescription'], pack['PrintDescription'].parameterize.underscore] }.uniq
  end
  
  #############################
  #     Class Methods         #
  #############################
  
  def to_csv
    require 'csv'
    headers = ['PrintDescription', 'TagNumber', 'PackStatus', 'InventoryStatus']
    
    CSV.generate(headers: true) do |csv|
      csv << headers
      
      scanned_packs.each do |scanned_pack|
        csv << [scanned_pack['PrintDescription'], scanned_pack['TagNumber'], scanned_pack['Status'], 'Scanned']
      end
      
      remaining_packs.each do |remaining_pack|
        csv << [remaining_pack['PrintDescription'], remaining_pack['TagNumber'], remaining_pack['Status'], 'Remaining']
      end
    end
  end
  
end