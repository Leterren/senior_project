require 'gosu'
require './lib/objects.rb'
require './lib/config'
require './lib/utility'
require './lib/objects'
include Utility

class Tenemy
  include TObject
  attr_accessor :HP, :damage, :x, :y

	def initialize(game, player, x, y, sprite = 'tplayer2.png')
		@game = game
		@player = player
		@x = x
		@y = y
	 	@@left, @@right = *Gosu::Image.load_tiles(game, "#{IMAGES_DIR}/#{sprite}", 50, 50, false)
	 	@face = @@left
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
		if !@dead
			@move_max.times do |i|
				newx = @x
				newy = @y
				distx = @player.x - @x
				disty = @player.y - @y
				if distx.abs <= 1 && disty.abs <= 1 && (distx.abs != disty.abs)
					@player.take_damage(@damage)
					@face = @@right if distx > 0
					@face = @@left if distx < 0
					break
				elsif distx.abs > disty.abs
					if distx > 0
						newx += 1
						@face = @@right
					else
						newx -= 1
						@face = @@left
					end
				else
					if disty > 0
						newy += 1
						@face = @@left
					else
						newy -= 1
						@face = @@right
					end
				end

				if @game.spot_clear?(newx, newy)
					@game.combatgrid[newy][newx] = self
					@game.combatgrid[@y][@x] = nil
					@x = newx
					@y = newy
				end
			end
		end	
  	return true
	end

	def take_damage (amount)
		@HP -= amount
		if @HP <= 0
			@game.combatgrid[@y][@x] = nil
			puts "#{@game.tobjects.delete(self)} dying"
			@dead = true
		end
	end
	
	def draw
		if @dead == false
			@face.draw(scale_x, scale_y, ZOrder::HUD)
			@game.main_font.draw("#{@HP} HP", scale_x + 1, scale_y + 50, ZOrder::HUD, 1, 1, 0xFFAAAAAA)
		end
	end

end
