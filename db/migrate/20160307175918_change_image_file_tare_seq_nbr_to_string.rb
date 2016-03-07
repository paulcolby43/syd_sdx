class ChangeImageFileTareSeqNbrToString < ActiveRecord::Migration
  def change
    change_column(:image_files, :tare_seq_nbr, :string)
  end
end
