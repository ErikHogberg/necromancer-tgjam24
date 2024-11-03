extends Node3D
class_name PlayerController

const JUMP_VELOCITY = 1
const GRAVITY = 0.980*5

@export var MoveSpeed: float = 60
@export var DirRef: Node3D
@export var SummonArea: Area3D

@export var zombiePrefab: PackedScene
var zombieParent: Node3D


var velocity: Vector3 = Vector3.ZERO
var resetPos: Vector3
var dead = false
var wasLeft = false

var summonMode=true
var mergeMode=true

var queueClick = false

signal on_move(pos: Vector2)
signal on_flip(left: bool)
signal show_summon_circle(on: bool)
signal summon

func is_on_floor() -> bool:
	return global_position.y < 0.01

func _ready() -> void:
	Global.player1 = self
		
	Global.add_friendly(self)
	resetPos = global_position
	zombieParent = get_node("/root/World")

func die():
	Global.remove_friendly(self)
	dead = true
	visible = false

func revive():
	Global.add_friendly(self)

func shoot():
	# project mouse pos on plane? select closest enemy in range and send homing projectile?
	pass
	
func do_summon():
	if summonMode:
		var stones = SummonArea.get_overlapping_bodies()
		for stone in stones:
			var zombie = zombiePrefab.instantiate() as Node3D
			zombieParent.add_child(zombie)
			zombie.global_position = stone.global_position
			Global.remove_stone(stone)
			stone.queue_free()
		summon.emit()

func _input(event: InputEvent) -> void:
	if dead: return
	if event is InputEventMouseButton:
		match event.button_index:
			#MOUSE_BUTTON_RIGHT:
				#show_summon_circle.emit(event.pressed)
				#if !event.pressed:
					#summon.emit()
			MOUSE_BUTTON_LEFT:
				if event.pressed:
					shoot()
					
		
	if event.is_action_pressed("summon"):
		show_summon_circle.emit(true)
	if event.is_action_released("summon"):
		show_summon_circle.emit(false)
		do_summon()
	if event.is_action_pressed("quit"):
		get_tree().quit()
	if event.is_action_pressed("reset player"):
		global_position = resetPos
	

func _process(delta: float) -> void:
	if dead: return
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += -GRAVITY * delta
	else:
		global_position.y = 0

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("a", "d", "w", "s")
	if abs(input_dir.x) > 0.1 && (input_dir.x < 0) != wasLeft:
		wasLeft = !wasLeft
		on_flip.emit(wasLeft)
	
	var refBasis = transform.basis
	if DirRef:
		#direction = direction.rotated(DirRef.global_position.signed_angle_to(global_position, Vector3.DOWN))
		refBasis = DirRef.global_basis
		global_rotation = DirRef.global_rotation
		
	var direction := (refBasis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if is_on_floor():
		if direction:
			velocity.x = direction.x * MoveSpeed * delta
			velocity.z = direction.z * MoveSpeed * delta
		else:
			velocity.x = move_toward(velocity.x, 0, MoveSpeed)
			velocity.z = move_toward(velocity.z, 0, MoveSpeed)
	
	global_position += velocity;
	if global_position.y < 0: global_position.y = 0
	
	on_move.emit(Vector2(global_position.x,global_position.z))

func _physics_process(delta: float) -> void:
	if !queueClick: return
	queueClick = false
	
	var space_state = get_world_3d().direct_space_state
	var cam = $Camera3D
	var mousepos = get_viewport().get_mouse_position()

	var origin = cam.project_ray_origin(mousepos)
	var end = origin + cam.project_ray_normal(mousepos) * 100
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true

	var result = space_state.intersect_ray(query)
	
func equip_raise():
	summonMode = true
func equip_splode():
	mergeMode = false
func equip_merge():
	mergeMode = true
func equip_consoom():
	summonMode= false
