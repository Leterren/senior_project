require 'gosu'
require './lib/objects.rb'
require './lib/config'
require './lib/utility'
require './lib/objects'

class Enemy
	include GameObject
	attr_accessor :combatresolved, :game, :sprite
	def to_a
		[@start.x, @start.y, @direction, @sprite]
  end
	def initialize (game, x, y, dir = :right, sprite)
      @game = game
    	space = game.space
      @sprite = sprite
    	@direction = dir
    	@@stand, @@walk1, @@walk2, @@jump = *Gosu::Image.load_tiles(
        	game, "#{IMAGES_DIR}/#{@sprite}", 50, 50, false
      	)
    	 # physicsy stuff
    	@body = CP::Body.new_static
    	@body.pos = Vec2.new(x, y)
    	@start = @body.pos
    	@body.object = self 
    	poly = [Vec2.new(-17, -20), Vec2.new(-17, 14), Vec2.new(-13, 19), Vec2.new(13, 19), Vec2.new(17, 14), Vec2.new(17, -20), Vec2.new(13, -25), Vec2.new(-13, -25)]
      	@shape = CP::Shape::Poly.new(@body, poly, Vec2.new(0, 0))
    	@shape.collision_type = :enemy
    	@shape.object = self
    	@shape.sensor = true
    	space.add_shape @shape
    	game.space.add_collision_handler(:player, :enemy, Enemy_Collisions.new)

    	@combatresolved = false
	end

	class Enemy_Collisions
  	def begin (player_s, enemy_s, contact)
    	player_s.object.message = "Combat!"
    	player_s.object.message_timer = 30
    	#enemy_s.object.combatresolved = true
      enemy_s.object.game.currentenemy = enemy_s.object
      enemy_s.object.game.load_combat
      enemy_s.object.game.state = :combat
      i=0
      while i < 2
        place = false
        x = rand(6)
        y = rand(6)
        while enemy_s.object.game.combatgrid[x][y] != nil
          x = rand(6)
          y = rand(6)
        end
        enemy_s.object.game.combatgrid[x][y] = i
        i += 1
      end
    end
  end

	def act ()
	end

	def react ()
		if @combatresolved
			self.unload()
		end
	end

 	def draw ()
 		if !combatresolved
    		x_scale = @direction == :left ? 1.0 : -1.0
    		frame = @@stand
    		frame.draw_rot(*game.camera.to_screen(@body.pos).to_a, ZOrder::OBJECTS, @body.a, 0.5, 0.5, x_scale)
		end
	end

	def click_area
    	Rect.new(@start.x - 17, @start.y - 25, @start.x + 17, @start.y + 25)
  end

  def unload ()
    	game.space.remove_shape @shape
  end

  def reset()
  end
end