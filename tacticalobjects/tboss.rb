require 'gosu'
require './lib/objects.rb'
require './lib/config'
require './lib/utility'
require './lib/objects'
include Utility

class Tboss
  include TObject
  attr_accessor :HP, :damage, :x, :y

	def initialize(game, player, x, y, sprite = 'tboss.png')
		@game = game
		@player = player
		@x = x
		@y = y
	 	@@left, @@right = *Gosu::Image.load_tiles(game, "#{IMAGES_DIR}/#{sprite}", 50, 50, false)
	 	@face = @@left
		@HP = 100
		@damage = 15
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

	def move
		
	end

	def take_turn
		if !@dead
			rando = rand(100)
			@move_max.times do |i|
				newx = @x
				newy = @y
				distx = @player.x - @x
				disty = @player.y - @y
				if distx.abs <= 2 && disty.abs <= 2 && (distx.abs != disty.abs)
					if rando >= 25
						#ATTACKING
						@flashtimer += 12
						@player.take_damage(@damage)
						@face = @@right if distx > 0
						@face = @@left if distx < 0
					end
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
			if rando < 25
				x = rand(6)
				y = rand(6)
				while @game.combatgrid[y][x] != nil
				x = rand(6)
				y = rand(6)
				end
				te = Tenemy.new(@game, @game.tp, x, y)
				@game.combatgrid[y][x] = te
				@game.tobjects << te
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
