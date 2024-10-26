extends Sprite3D
class_name Zombie

enum State {Idle, Attacking, Chasing, Thinking}

@export var ThinkTime= 1.0
@export var SwingTime= 1.0
@export var MeleeDistance= 1.0

var target: Node3D
var currentState = State.Idle
var nextState = State.Idle

var attackTimer = -1.0
var thinkingTimer = -1.0

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

func enter_state(new_state: State):
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
			pass
		State.Attacking:
			attackTimer-=delta
			if attackTimer<0:
				attack()
		State.Chasing:
			chase()
		State.Thinking:
			thinkingTimer -= delta
			if thinkingTimer < 0:
				enter_state(nextState)
