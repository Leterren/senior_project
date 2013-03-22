require 'gosu'
require './lib/objects.rb'
require './lib/config'
require './lib/utility'
require './lib/objects'
include Utility

class Tplayer

	def initialize(game, player, x, y, sprite = 'player.png')
		@HP = player.currentHP
		@player = player
		@damage = 20
		@move_max = 4
		@current_move = 0
	end

	def act ()
		
	end

	def draw

	end


end