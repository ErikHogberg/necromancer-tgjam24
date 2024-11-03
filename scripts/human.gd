extends Node3D
class_name Human

enum State { Idle, Attacking, Chasing, Thinking}

@export var TombstonePrefab: PackedScene

@export var ThinkTime= .1
@export var SwingTime= 1.0
@export var MeleeDistance= 1.0
@export var SightDistance= 10.0
@export var FollowDistance= 2.0


const FOLLOW_SPEED = 10.0
const a = 2
const avoidance_dist: float = a * a

const followMinMax = Vector2(1,1000)
const speedMinMax = Vector2(0.1,100)

@export var currentState = State.Idle

var target: Node3D
var nextState = State.Idle

var attackTimer = -1.0
var thinkingTimer = -1.0


func die():
	Global.remove_hostile(self)
	var a = TombstonePrefab.instantiate() as Node3D
	get_node("/root/World").add_child(a)
	a.global_position = global_position
	queue_free()
	
func revive():
	Global.add_hostile(self)

func _ready():
	revive()

func attack():
	if !target:
		enter_state(State.Idle)
		return
	
	# todo: swing
	
	if target.global_position.distance_squared_to(global_position) > MeleeDistance*MeleeDistance:
		nextState = State.Chasing
		enter_state(State.Thinking)
	else:
		# todo: transfer dmg
		Global.take_dmg()
		enter_state(State.Attacking) # re-init attack state

func chase(delta: float):
	if !target:
		enter_state(State.Idle)
		return
		
	if target.global_position.distance_squared_to(global_position) < MeleeDistance*MeleeDistance:
		enter_state(State.Attacking)
	else: 
		global_position = global_position.move_toward(target.global_position, delta*100)


func enter_state(new_state: State):
	#print("enter state ", State.keys()[new_state])
	currentState = new_state
	match new_state:
		State.Idle:
			# todo: set animation
			pass
		State.Attacking:
			# todo: set animation
			attackTimer = SwingTime
			pass
		State.Chasing:
			# todo: set animation
			pass
		State.Thinking:
			thinkingTimer = ThinkTime

func think_then_enter_state(new_state: State):
	nextState = new_state
	enter_state(State.Thinking)

func _process(delta: float) -> void:
	match currentState:
		State.Idle:
			if Global.player1.global_position.distance_squared_to(global_position) < SightDistance*SightDistance:
				target = Global.player1
				enter_state(State.Chasing)
		State.Attacking:
			attackTimer -= delta
			if attackTimer < 0:
				attack()
		State.Chasing:
			chase(delta)
		State.Thinking:
			thinkingTimer -= delta
			if thinkingTimer < 0:
				enter_state(nextState)
