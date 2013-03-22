require 'gosu'
require './lib/objects.rb'
require './lib/config'
require './lib/utility'
require './lib/objects'
include Utility

class Tplayer
  include TObject
  attr_accessor :x, :y

	def initialize(game, player, x, y, sprite = 'player.png')
		@game = game
		@x = x
		@y = y
		@HP = player.currentHP
		@player = player
		@damage = 20
		@move_max = 4
		@current_move = 0
		@attack_state = :notyet #:notyet, :aiming, and :finished 
		@turn_end = false
	end

	def scale_x
		return (25 + (100*@x))
	end

	def scale_y
		return (25 + (100*@y))
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
			if @attack_state == :notyet
				@attack_state = :aiming
			end
		end

		if id==Gosu::KbUp
			if @attack_state == :aiming
				#attack space up
				if @game.combatgrid[@x-1][@y] != nil
					@game.combatgrid[@x-1][@y].HP -= @damage
				end
				@attack_state = :finished
			else
				if (@current_move < @move_max) && (x > 0) && (@game.combatgrid[@x-1][@y] == nil)
					@game.combatgrid[@x-1][@y] = self
					@game.combatgrid[@x][@y] = nil
					@x -= 1
					@current_move += 1
					#@game.printgrid
				end
			end
		end
		
		if id==Gosu::KbDown
			if @attack_state == :aiming
				#attack space down
				if @game.combatgrid[@x+1][@y] != nil
					@game.combatgrid[@x+1][@y].HP -= @damage
				end
				@attack_state = :finished
			else
				if (@current_move < @move_max) && (x < 5) && (@game.combatgrid[@x+1][@y] == nil)
					@game.combatgrid[@x+1][@y] = self
					@game.combatgrid[@x][@y] = nil
					@x += 1
					@current_move += 1
					#@game.printgrid
				end
			end
		end
		
		if id==Gosu::KbLeft
			if @attack_state == :aiming
				#attack space left
				if @game.combatgrid[@x][@y-1] != nil
					@game.combatgrid[@x][@y-1].HP -= @damage
				end
				@attack_state = :finished
			else
				if (@current_move < @move_max) && (y > 0) && (@game.combatgrid[@x][@y-1] == nil)
					@game.combatgrid[@x][@y-1] = self
					@game.combatgrid[@x][@y] = nil
					@y -= 1
					@current_move += 1
					#@game.printgrid
				end
			end
		end
		
		if id==Gosu::KbRight
			if @attack_state == :aiming
				#attack space right
				if @game.combatgrid[@x][@y+1] != nil
					@game.combatgrid[@x][@y+1].HP -= @damage
				end
				@attack_state = :finished
			else
				if (@current_move < @move_max) && (y < 5) && (@game.combatgrid[@x][@y+1] == nil)
					@game.combatgrid[@x][@y+1] = self
					@game.combatgrid[@x][@y] = nil
					@y += 1
					@current_move += 1
					#@game.printgrid
				end
			end
		end
	end

	def take_turn
		if @turn_end == true
			@current_move = 0
			@attack_state = :notyet
			@turn_end = false
			return true
		end
	end

	def draw
		@game.draw_quad(scale_y, scale_x, 0xFF0000FF, scale_y + 50, scale_x, 0xFF0000FF, scale_y + 50, scale_x + 50, 0xFF0000FF, scale_y, scale_x + 50, 0xFF0000FF)
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
	end

end
