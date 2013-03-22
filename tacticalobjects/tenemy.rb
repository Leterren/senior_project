require 'gosu'
require './lib/objects.rb'
require './lib/config'
require './lib/utility'
require './lib/objects'
include Utility

class Tenemy
  include TObject

	def initialize(game, x, y, sprite = 'player2.png')
		@game = game
	 	@@stand, @@walk1, @@walk2, @@jump = *Gosu::Image.load_tiles(game, "#{IMAGES_DIR}/#{sprite}", 50, 50, false)
		@HP = 40
		@damage = 8
		@move_max = 2

	end

	def take_turn
		 # TODO: insert AI here
  	return true
	end

	def draw

	end

end
