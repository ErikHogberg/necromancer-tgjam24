extends Node3D
class_name Zombie

enum State { Idle, Follow, Attacking, Chasing, Thinking}

@export var ThinkTime= 1.0
@export var SwingTime= 1.0
@export var MeleeDistance= 1.0
@export var SightDistance= 10.0
@export var FollowDistance= 2.0

const FOLLOW_SPEED = 10.0

@export var currentState = State.Idle
var target: Node3D
var nextState = State.Idle

var attackTimer = -1.0
var thinkingTimer = -1.0

func die():
	Global.remove_friendly(self)
	
func revive():
	Global.add_friendly(self)

func _ready():
	revive()
	

func attack():
	if !target:
		enter_state(State.Idle)
		return
	
	if target.global_position.distance_squared_to(global_position) > MeleeDistance*MeleeDistance:
		enter_state(State.Chasing)

	
func chase():
	if !target:
		enter_state(State.Idle)
		return
		
	if target.global_position.distance_squared_to(global_position) < MeleeDistance*MeleeDistance:
		enter_state(State.Attacking)

func follow(delta: float):
	if !target:
		enter_state(State.Idle)
		return
	if target.global_position.distance_squared_to(global_position) > FollowDistance*FollowDistance:
		global_position = global_position.move_toward(target.global_position, delta*FOLLOW_SPEED)
		global_position.y = 0

func enter_state(new_state: State):
	print("enter state ", State.keys()[new_state])
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
		State.Follow:
			pass

func think_then_enter_state(new_state: State):
	nextState = new_state
	enter_state(State.Thinking)

func _process(delta: float) -> void:
	
	match currentState:
		State.Idle:
			if Global.player.global_position.distance_squared_to(global_position) < SightDistance*SightDistance:
				target = Global.player
				enter_state(State.Follow)
		State.Attacking:
			attackTimer -= delta
			if attackTimer < 0:
				attack()
		State.Follow:
			follow(delta)
		State.Chasing:
			chase()
		State.Thinking:
			thinkingTimer -= delta
			if thinkingTimer < 0:
				enter_state(nextState)
