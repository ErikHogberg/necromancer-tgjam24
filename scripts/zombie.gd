extends Node3D
class_name Zombie

enum State { Idle, Follow, Attacking, Chasing, Thinking}

@export var ThinkTime= 1.0
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
		
	var oldPos = global_position
	var avoidance = Vector3.ZERO
	var closestFriendly = Global.get_closest_friendly(global_position, self)
	if closestFriendly and closestFriendly.global_position.distance_squared_to(global_position) < avoidance_dist:
		avoidance = -global_position.direction_to(closestFriendly.global_position)
		global_position += avoidance * (delta * FOLLOW_SPEED)
		
	var dist = target.global_position.distance_to(global_position)
	if dist > FollowDistance:
		var distLerp = (dist - followMinMax.x) / (followMinMax.y-followMinMax.x)
		var speed = distLerp* (speedMinMax.y-speedMinMax.x) + speedMinMax.x
		global_position = global_position.move_toward(target.global_position, delta*speed*FOLLOW_SPEED)
		global_position.y = 0
	
	var dirAngle =oldPos.signed_angle_to(global_position, Vector3.DOWN)
	
	#turn.emit(dirAngle)
	rotation.y = dirAngle

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
		State.Follow:
			pass

func think_then_enter_state(new_state: State):
	nextState = new_state
	enter_state(State.Thinking)

func _process(delta: float) -> void:
	
	match currentState:
		State.Idle:
			if Global.player1.global_position.distance_squared_to(global_position) < SightDistance*SightDistance:
				target = Global.player1
				enter_state(State.Follow)
			elif Global.player2 and Global.player2.global_position.distance_squared_to(global_position) < SightDistance*SightDistance:
				target = Global.player2
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
