require 'gosu'
require './lib/objects.rb'
require './lib/config'
require './lib/utility'
require './lib/objects'
include Utility

class Tplayer
  include TObject

	def initialize(game, player, x, y, sprite = 'player.png')
		@HP = player.currentHP
		@player = player
		@damage = 20
		@move_max = 4
		@current_move = 0
	end

	def take_turn
		 # TODO: player logic
		return false
	end

	def draw

	end


end
