
require_relative 'minesweeper.rb'
module Minesweeper

  class Game

    def initialize(rows,columns,mines)
      @minesweeper = Minesweeper.new(rows,columns,mines)  
      move 
    end

    def move       
      @minesweeper.play
    end
  
  end

end

Minesweeper::Game.new(7,7,5)

