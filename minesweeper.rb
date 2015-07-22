# Game Rules
# 1. Board is 2-D space with a predetermined number of mines
# 2. Cells have two states, open and closed
# 3. 
# 
# 
module Minesweeper

  class Minesweeper

    def initialize(rows,columns,mines)
      @mines = mines
      @rows = rows
      @columns = columns
      @flagged_tiles = []
      @open_tiles = []
      #Each board space is a Tile Class
      @game_board = Array.new(rows*columns)
      setup
      assign_mines
      set_mine_counts
      #print_board
    end
    attr_reader :columns, :rows, :game_board

    def setup
      (0...@rows).each do |y|
        (0...@columns).each do |x|
          @game_board[x+@columns*y] = Tile.new(x,y)
        end
      end

    end

    def assign_mines
      sample = @game_board.shuffle(random: Random.new).first(@mines)
      sample.map {|tile| tile.mine = true}
    end

    def set_mine_counts
      @game_board.each do |tile|
        tile.adjacent_tiles.each do |key,value|
          x = value[0]
          y = value[1]
          adjacent_tile = @game_board[x+@columns*y]
          #puts adjacent_tile
          tile.adjacent_mine_count += 1 if is_inside?(x,y) && adjacent_tile.mine?
          #puts @adjacent_mine_count
        end
      tile.has_adjacent_mines = true if tile.adjacent_mine_count > 0
      end
    end
    
    def open_cell(tile) 
    #This is what will be called when user *clicks on a cell
    # If the tile clicked has a mine, the user loses
    # else
    #   Cell is emtpy and opened and will have two cases
    #     1. if any adjacent cells have mines, opened cell will show # of surrouding mines
    #     2. if no adjacent cells have mines, will open all these cells
    #     
    tile.open!
    if tile.has_adjacent_mines
      return 
    else
      tile.adjacent_tiles.each do |key,value|
        x = value[0]
        y = value[1]
        if is_inside?(x,y)
          new_tile = @game_board[x + @columns*y]
          open_cell(new_tile) unless new_tile.open
        else
          next
        end
      end
    end

    end

    def flag_tile(tile)
      tile.flag!
      if @flagged_tiles.include?(tile)
        @flagged_tiles.delete_if {|t| t == tile}
      else
        @flagged_tiles << tile
      end
    end

    def win?
      if !@flagged_tiles.empty?
        return true if (@flagged_tiles.all? {|tile| tile.mine} && @flagged_tiles.length == @mines)
      end
      false
    end

    def play

      # User input is structured as follows
      # >> 'tag x y' 
      #  x y represent the coordinates of the square requested to be played in non-zero based notation
      # 'tag' coorsponds to the type of move:
      #   o (or O) coorsponds to opening a square
      #   f (of F) coorsponds to flagging a square (it will toggle flag on/off depending on initial state)
      loop do
        print_board
        puts "Enter your move" ## No defensive programming yet
        input = gets.chomp.lstrip.downcase


        moves = input.split(" ")
        move_type = moves[0]
        x = moves[1].to_i - 1
        y = moves[2].to_i - 1
        tile = @game_board[x + @columns*y]

        
        if move_type == "f" # Flag given input position
          flag_tile(tile)
          if win?
            puts "You win!"
            break
          end
        end

        if move_type == "o" and tile.mine
          puts "Game Over!"
          break
        end

        

        if move_type == "o" and !tile.mine
            open_cell(tile) if !tile.open
        end

      end

    end


    def print_board
      puts "Total mines: #{@mines}, Mines left: #{@mines - @flagged_tiles.length}"
      col_sep = " | " 
      row_sep = "\n" + "----"*@columns + "\n"
      output = [(0..@columns).to_a.join(col_sep)]
      (0...@rows).each do |y|
        row = ["#{y+1} "]
        (0...@columns).each do |x|
          tile = @game_board[x+@columns*y]
          row << tile.get_marker      
        end
        output << row.join(col_sep)
      end
      puts output.join(row_sep)
    end

    def is_inside?(x,y)
      x >= 0 and x < @columns and y >= 0 and y < @rows
    end

    def game_over?(x,y)
      @game_board[x + @columns*y].mine
    end

  end

  class Tile

    def initialize(x,y)
      @mine = false
      @x = x
      @y = y

      @flagged = false
      @open = false
      @has_adjacent_mines = false
      @adjacent_mine_count = 0
      @adjacent_tiles = {
          left: [@x-1,@y],
          up_left: [@x-1,@y+1],
          up: [@x,@y+1],
          up_right: [@x+1, @y+1],
          right: [@x+1,@y],
          down_right: [@x+1,@y-1],
          down: [@x,@y-1],
          down_left: [@x-1,@y-1]
      }
    end

    attr_accessor  :has_adjacent_mines, :x, :y, :mine, :adjacent_mine_count
    attr_reader :adjacent_tiles, :flagged, :open

    def mine?
      @mine
    end

    def open!
      @open = true
    end

    def flag!
      if @flagged 
        @flagged = false
      else
        @flagged = true
      end
    end

    def get_marker

      if @flagged
        return "F"
      elsif @open and @adjacent_mine_count > 0
        return @adjacent_mine_count.to_s
      elsif @open
        return " "
      else
        return "*"
      end
    end


  end

  
end

