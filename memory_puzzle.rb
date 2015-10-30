require 'byebug'

class Card
  attr_reader  :card_state, :card_value

  def initialize(card_value)
    @card_value = card_value
    @card_state = :down
  end

  def hide
    @card_state = :down
  end

  def reveal
    @card_state = :up
  end

  def state?
    card_state
  end

  def value?
    card_value
  end

  def to_s
    if self.state? == :up
      " #{card_value} "
    else
      " X "
    end
  end
end

class Board
  attr_reader :grid, :size

  def initialize(grid = blank_grid)
    @grid = grid
    @size = 4
    populate
  end

  def blank_grid
    Array.new(4) { Array.new(4) }
  end

  def populate
    cards = []
     2.times do
      ("A".."H").each { |letter| cards << Card.new(letter)}
    end
    # debugger
    place_cards(cards)
  end

  def place_cards(cards)
    shuffled_cards = cards.shuffle
    (0...4).each do |row|
      (0...4).each do |col|
        pos = [row , col]
        self[pos] = shuffled_cards.pop
      end
    end
  end

  def random_position
    [rand(4), rand(4)]
  end

  def empty?(pos)
    self[pos].nil?
  end

  def [](pos)
    row, col = pos
    grid[row][col]
  end

  def []=(pos, val)
    row, col = pos
    grid[row][col] = val
  end

  def render
    system('clear')
    header = (0..4).to_a.join("   ")
    p "   #{header} "
    @grid.each_with_index do |row, i|
      chars = row.map do |card|
        # display_card(card)
        card.to_s
      end.join("  ")
      p "#{i} #{chars}"
    end
  end

  def complete
    @grid.flatten.all? { |card| card.state? == :up }
  end

  def within_bounds?(*guess)
    guess.each { |cord| cord.to_i.between?(-1, 4) }
  end

  def reveal(guess)
    card = self[guess]
    card.reveal
  end
end

class Game
  def initialize(player, board = Board.new)
    @player = player
    @first_guess = 0
    @second_guess = nil
    @board = board
    @match = false
  end

  attr_reader :player, :first_guess, :second_guess, :board, :match

  def play
    play_turn until over?
    puts "You won!"
  end

  def play_turn
    system("clear")
    board.render
    get_guesses
    check_for_match
    wait
    reset
  end

  def valid_guess?(guess)
    board.within_bounds?(guess) &&
    first_guess != second_guess
  end

  def over?
    board.complete
  end

  def check_for_match
    @match = true if board[@first_guess].value? == board[@second_guess].value?
  end

  def get_guesses
# debuexiygger
    @first_guess = prompt
    board.reveal(first_guess)
    board.render
    @second_guess = prompt
    board.reveal(second_guess)
    board.render
  end

  def prompt
    puts "Pick a card."
    guess = gets.chomp
    until valid_guess?(guess)
      guess = gets.chomp
    end
    guess.split(",").map { |el| el.to_i }
  end

  def reset
    if match == false
      board[first_guess].hide
      board[second_guess].hide
    end
    @match = false
    @first_guess = 0
    @second_guess = nil
  end

  def wait
    continue = ''

    puts "press enter to continue"
    continue = gets
  end
end

if __FILE__ == $PROGRAM_NAME
  # jane = Player.new("Jane")
  game = Game.new("jane")
  game.play
end
