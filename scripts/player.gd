extends CharacterBody2D

class_name Player

@export var max_hp = 10
var hp = 10

@onready var reveal_zone: RevealZone = $RevealZone

@onready var player_sprite: AnimatedSprite2D = $Future
@onready var item_sprite: Sprite2D = $Future/ItemSprite

@export var SPEED = 100.0
@export var JUMP_VELOCITY = -200.0
@export var JUMP_DETECTION_THRESHOLD = 50
@export var CLIMB_SPEED = 75
const ITEM_SHIFT = 7
var currentMask = RevealZone.Mode.NOW
var can_climb := false
var is_climbing := false

var nearby_interactions: Array[Interactable] = []

func _ready() -> void:
	InventoryManager.item_changed.connect(onItemChange)

func onItemChange(new_item: Item):
	if new_item != null:
		item_sprite.texture = new_item.in_hand_texture
	else:
		item_sprite.texture = null

func _physics_process(delta: float) -> void:
	_handle_movement(delta)
	_handle_interactions_input()
	reveal_zone.update_if_needed(global_position)

func _process(_delta: float) -> void:
	_play_movemement_animations()
	
func _handle_movement(delta: float):
	#if Input.is_action_just_pressed("mask_past"):
		#currentMask = RevealZone.Mode.PAST
		#reveal_zone.set_mode(currentMask)
		#reveal_zone.update_if_needed(global_position)
		#print(1)
	#if Input.is_action_just_pressed("mask_now"):
		#currentMask = RevealZone.Mode.NOW
		#reveal_zone.set_mode(currentMask)
		#reveal_zone.update_if_needed(global_position)
		#print(2)
	#if Input.is_action_just_pressed("mask_future"):
		#currentMask = RevealZone.Mode.FUTURE
		#reveal_zone.set_mode(currentMask)
		#reveal_zone.update_if_needed(global_position)
		#print(3)
	# Add the gravity.
	if not is_on_floor() and not is_climbing:
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	var input_y := Input.get_axis("move_up", "move_down")
	# Start/stop climbing when inside ladder area
	#print(input_y, can_climb, is_climbing)
	if can_climb and abs(input_y) > 0.0:
		is_climbing = true
	elif not can_climb:
		is_climbing = false

	if is_climbing:
		# no gravity while climbing
		velocity.y = input_y * CLIMB_SPEED
	

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	
	if direction:
		velocity.x = direction * SPEED
		var isWalkingLeft: bool = velocity.x <= 0
		player_sprite.flip_h = isWalkingLeft
		item_sprite.flip_h = !isWalkingLeft
		item_sprite.position = Vector2(-ITEM_SHIFT, 0) if isWalkingLeft else Vector2(ITEM_SHIFT, 0)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)	


	move_and_slide()
	
# Interactions
func _handle_interactions_input():
	if Input.is_action_just_pressed("interact"):
		_try_interact()
#
func _try_interact():
	if not nearby_interactions:
		return
	var interaction = nearby_interactions.get(0)
	if interaction.can_interact():
		interaction.interact()
		if interaction.only_once:
			nearby_interactions.erase(interaction)
	

func _on_interaction_zone_area_entered(area: Area2D) -> void:
	if area is Interactable:
		nearby_interactions.append(area)

func _on_interaction_zone_area_exited(area: Area2D) -> void:
	if area is Interactable:
		nearby_interactions.erase(area)
		
		
func _play_movemement_animations():
	if not is_on_floor():
		if velocity.y > 0 and player_sprite.animation.begins_with("fall"):
			_play_animation("fall")
		if velocity.y < 0 and player_sprite.animation.begins_with("jump"):
			_play_animation("jump")
	else:
		if velocity.x != 0:
			_play_animation("walk")
		else:
			_play_animation("idle")
			
func _play_animation(animation):
	player_sprite.play(animation + "_" + str(MaskManager.current_mask))
	
