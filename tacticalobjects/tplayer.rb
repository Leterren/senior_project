require 'gosu'
require './lib/objects.rb'
require './lib/config'
require './lib/utility'
require './lib/objects'
include Utility

class Tplayer
  include TObject
  attr_accessor :x, :y, :scale_x, :scale_y

	def initialize(game, player, x, y, sprite = 'tplayer.png')
		@game = game
		@x = x
		@y = y
		@player = player
		@left, @right = *Gosu::Image.load_tiles(game, "#{IMAGES_DIR}/#{sprite}", 50, 50, false)
		@face = @left

      	@damage = @player.strength * 5
      	@move_max = @player.agility
      	@defense = @player.defense

		@path = []
		@current_move = 0
		@attack_state = :notyet #:notyet, :aiming, and :finished 
		@aimx = 0
		@aimy = 0 
		@flash_timer = 0
		@turn_end = false
	end

	def scale_x
		return (25 + (100*@x))
	end

	def scale_y
		return (25 + (100*@y))
	end

	def try_move (tox, toy)
	  if @game.spot_clear?(tox, toy)
			  rewind = @path.index([tox, toy])
			  move_success = false
			  if rewind
			    oldlen = @path.length
			    @path = @path[0,rewind]
			    @current_move -= oldlen - @path.length
          move_success = true
				elsif @current_move < @move_max
					@path << [@x, @y]
				  @current_move += 1
				  move_success = true
				end
				if move_success
					@game.combatgrid[toy][tox] = self
					@game.combatgrid[@y][@x] = nil
					@x, @y = tox, toy
				end
	  end
  end

  def try_attack (tox, toy)
    if @game.spot_occupied?(tox, toy)
      @game.combatgrid[toy][tox].take_damage(@damage)
      @aimx = tox
      @aimy = toy
      @flash_timer += 12
    end
    @attack_state = :finished
    @path = []
  end

	def button_down(id)
		if id==Gosu::KbEnter || id==Gosu::KbReturn
			@turn_end = true
			#@game.tobjects.each do |o|
			#	puts o.class
			#end
			#puts "**"
		end

		if id==Gosu::KbSpace
			if @attack_state == :aiming
				@attack_state = :notyet
			elsif @attack_state == :notyet
				@attack_state = :aiming
			end
		end

		if id==Gosu::KbUp
			@face = @right
			if @attack_state == :aiming
			  try_attack(@x, @y-1)
			else
			  try_move(@x, @y-1)
			end
		end
		
		if id==Gosu::KbDown
			@face = @left
			if @attack_state == :aiming
			  try_attack(@x, @y+1)
			else
			  try_move(@x, @y+1)
			end
		end
		
		if id==Gosu::KbLeft
			@face = @left
			if @attack_state == :aiming
			  try_attack(@x-1, @y)
			else
			  try_move(@x-1, @y)
			end
		end
		
		if id==Gosu::KbRight
			@face = @right
			if @attack_state == :aiming
			  try_attack(@x+1, @y)
			else
			  try_move(@x+1, @y)
			end
		end
	end

	def take_turn
		#@game.lose_combat if @player.currentHP <= 0
		if @player.currentHP <= 0
			@game.combatgrid[@y][@x] = nil 
			@game.tobjects.delete(self)
		end
		if @turn_end == true
			@current_move = 0
			@path = []
			@attack_state = :notyet
			@turn_end = false
			return true
		end
	end

	def draw
	  	@path.each_index do |i|
	    	p2 = i+1 == @path.length ? [@x,  @y] : @path[i+1]
	    	@game.draw_line(
	    		50 + 100 * @path[i][0], 75 + 100 * @path[i][1], 0xFFFFFFFF,
	    	  	50 + 100 * p2[0], 75 + 100 * p2[1], 0xFFFFFFFF
	    	)
	  	end
	  	@face.draw(scale_x, scale_y, ZOrder::HUD)
	  	@game.main_font.draw("Current HP: #{@player.currentHP}", 630, @game.height/4 - 70, ZOrder::HUD, 1, 1, 0xFFFF1111)
	  	@game.main_font.draw("Moves Left: #{@move_max - @current_move}", 630, @game.height/4 - 50, ZOrder::HUD, 1, 1, 0xFF888888)
	
	  	if @attack_state == :notyet
			@game.main_font.draw("Attack Available", 630, @game.height/4 - 30, ZOrder::HUD, 1, 1, 0xFF888888)
			@game.main_font.draw("[Space]", 635, @game.height/4 - 10, ZOrder::HUD, 1, 1, 0xFF888888)
	  	elsif @attack_state == :aiming
			@game.main_font.draw("Aiming...", 630, @game.height/4 - 30, ZOrder::HUD, 1, 1, 0xFF888888)
			@game.main_font.draw("[^ v < >]", 635, @game.height/4 - 10, ZOrder::HUD, 1, 1, 0xFF888888)
	  	else
			@game.main_font.draw("Attack Complete", 630, @game.height/4 -30, ZOrder::HUD, 1, 1, 0xFF888888)
	  	end
		if @flash_timer > 0
			@game.draw_quad(
				(@aimx * 100) + 12, (@aimy * 100) + 12, 0x55FF0000, 
				(@aimx * 100) + 92, (@aimy * 100) + 12, 0x55FF0000, 
				(@aimx * 100) + 92, (@aimy * 100) + 92, 0x55FF0000, 
				(@aimx * 100) + 12, (@aimy * 100) + 92, 0x55FF0000, 
				ZOrder::HUD, mode = :default) if (@flash_timer >= 6
			)
			@flash_timer -= 1
		end
	end

	def take_damage(damage)
		actualdamage = damage - (@defense)
		if actualdamage < 0
			actualdamage = 0
		end
		if actualdamage < @player.currentHP
			@player.currentHP -= actualdamage
		else
			@player.currentHP = 0
		end
	end

end
