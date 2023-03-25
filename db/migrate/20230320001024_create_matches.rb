class CreateMatches < ActiveRecord::Migration[6.1]
  def change
    create_table :matches do |t|
      t.string :player1_id
      t.string :player2_id
      t.string :set1
      t.string :set2
      t.string :set3
      t.string :set4
      t.string :set5

    end
  end
end
