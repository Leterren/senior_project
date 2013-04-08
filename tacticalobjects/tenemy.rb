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
		@damage = 10
		@move_max = 2
		@dead = false
		@flashtimer = 0
	end

	def scale_x
		return (25 + (100*@x))
	end

	def scale_y
		return (25 + (100*@y))
	end

	def take_turn
		if !@dead
			@move_max.times do |i|
				newx = @x
				newy = @y
				distx = @player.x - @x
				disty = @player.y - @y
				if distx.abs <= 1 && disty.abs <= 1 && (distx.abs != disty.abs)
					#ATTACKING
					@flashtimer += 12
					@player.take_damage(@damage)
					face_player
					break
				else
					if distx > 0 then newx += 1 else newx -= 1 end
					if disty > 0 then newy += 1 else newy -= 1 end
				end

				face_player

				# try to move on furthest axis, if blocked move on other axis
				# TODO: multi-turn movement plans (around obstacles)
				if distx.abs > disty.abs
					move_to(@x, newy) unless move_to(newx, @y)
				else
					move_to(newx, @y) unless move_to(@x, newy)
				end

			end
		end	
  	return true
	end

	def face_player
		distx = @player.x - @x
		disty = @player.y - @y
		if distx.abs > disty.abs
			@face = @@right if distx > 0
			@face = @@left if distx < 0
		else
			@face = @@left if disty > 0
			@face = @@right if disty < 0
		end
	end

	def move_to x,y
		if @game.spot_clear?(x,y)
			@game.combatgrid[y][x] = self
			@game.combatgrid[@y][@x] = nil
			@x = x
			@y = y
			return true
		end

		return false
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
			if @flashtimer > 0
				@game.draw_quad(0, 0, 0x55FF0000, 
								@game.width, 0, 0x55FF0000, 
								@game.width, @game.height, 0x55FF0000, 
								0, @game.height, 0x55FF0000, 
								ZOrder::HUD, mode = :default) if (@flashtimer >= 6)
				@flashtimer -= 1
			end
		end
	end

end
