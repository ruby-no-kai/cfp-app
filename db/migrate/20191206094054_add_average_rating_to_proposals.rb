class AddAverageRatingToProposals < ActiveRecord::Migration[5.2]
  def change
    add_column :proposals, :average_rating, :float
  end
end
