require 'gosu'
require './lib/objects.rb'
require './lib/config'
require './lib/utility'
require './lib/objects'
include Utility

class Tenemy
  include TObject
  attr_accessor :HP, :damage, :x, :y

	def initialize(game, player, x, y, sprite = 'player2.png')
		@game = game
		@player = player
		@x = x
		@y = y
	 	@@stand, @@walk1, @@walk2, @@jump = *Gosu::Image.load_tiles(game, "#{IMAGES_DIR}/#{sprite}", 50, 50, false)
		@HP = 40
		@damage = 8
		@move_max = 2
		@dead = false
	end

	def scale_x
		return (25 + (100*@x))
	end

	def scale_y
		return (25 + (100*@y))
	end

	def move
		
	end

	def take_turn

		# am i dead?
		if @HP <= 0
			@dead = true
			@game.combatgrid[@x][@y] = nil
			@game.tobjects.delete(self)
		end

		
		@move_max.times do |i|
			newx = @x
			newy = @y
			distx = @player.x - @x
			disty = @player.y - @y
			if distx.abs <= 1 && disty.abs <= 1 && (distx.abs != disty.abs)
				puts "#{self} attacking"
				@player.takedamage(@damage)
				break
			elsif distx.abs > disty.abs
				puts "#{self} approaching on x"
				if distx > 0
					newx += 1
				else
					newx -= 1
				end
			else
				puts "#{self} approaching on y"
				if disty > 0
					newy += 1
				else
					newy -= 1
				end
			end

			if @game.combatgrid[newx][newy].nil?
				@game.combatgrid[newx][newy] = self
				@game.combatgrid[@x][@y] = nil
				@x = newx
				@y = newy
			end
		end
		
		
  	return true
	end

	def draw
		if @dead == false
			@game.draw_quad(scale_y, scale_x, 0xFFAA0000, scale_y + 50, scale_x, 0xFFAA0000, scale_y + 50, scale_x + 50, 0xFFAA0000, scale_y, scale_x + 50, 0xFFAA0000)
			@game.main_font.draw("#{@HP} HP", scale_y + 1, scale_x + 50, ZOrder::HUD, 1, 1, 0xFFAAAAAA)
		end
	end

end
