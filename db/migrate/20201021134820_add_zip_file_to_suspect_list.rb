class AddZipFileToSuspectList < ActiveRecord::Migration
  def change
    add_column :suspect_lists, :zip_file, :string
  end
end
