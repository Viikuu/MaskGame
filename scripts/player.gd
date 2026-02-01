extends CharacterBody2D

class_name Player

@export var max_hp = 10
var hp = 10

var coyote_timer = 0

@onready var death_timer: Timer = $DeathTimer
@onready var death_animation_player: AnimationPlayer = $DeathAnimationPlayer
@onready var reveal_zone: RevealZone = $RevealZone

@onready var player_sprite: AnimatedSprite2D = $Future
@onready var item_sprite: Sprite2D = $Future/ItemSprite

@onready var jump_sound: AudioStreamPlayer2D = $Audio/JumpSound
@onready var walking_sound: AudioStreamPlayer2D = $Audio/WalkingSound
@onready var item_pickup_sound: AudioStreamPlayer2D = $Audio/ItemPickupSound
@onready var interaction_sound: AudioStreamPlayer2D = $Audio/InteractionSound
@onready var mask_change_sound: AudioStreamPlayer2D = $Audio/MaskChangeSound

@export var SPEED = 100.0
@export var JUMP_VELOCITY = -200.0
@export var CLIMB_SPEED = 75
@export var COYOTE_TIME = 0.1

const ITEM_SHIFT = 7

const CAMERA_SHIFT_ACCELERATION = 1
const CAMERA_MAX_SHIFT = 100

var can_climb := false
var is_climbing := false

var nearby_interactions: Array[Interactable] = []

func _ready() -> void:
	InventoryManager.item_changed.connect(onItemChange)
	MaskManager.mask_changed.connect(onMaskChange)
	
func onMaskChange(oldMask, newMask):
	if newMask != oldMask:
		mask_change_sound.play()

func onItemChange(new_item: Item):
	if new_item != null:
		item_sprite.texture = new_item.in_hand_texture
		item_pickup_sound.play()
	else:
		if item_sprite.texture != null:
			interaction_sound.play()	
		item_sprite.texture = null

func _physics_process(delta: float) -> void:
	_handle_movement(delta)
	_handle_interactions_input()
	reveal_zone.update_if_needed(global_position)

func _process(_delta: float) -> void:
	_play_movemement_animations()
	
func _handle_movement(delta: float):
	# Add the gravity.
	if not is_on_floor() and not is_climbing:
		velocity += get_gravity() * delta
	
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer -= delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and coyote_timer > 0:
		velocity.y = JUMP_VELOCITY
		
	var input_y := Input.get_axis("move_up", "move_down")
	# Start/stop climbing when inside ladder area
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
	for interaction in nearby_interactions:
		if interaction.can_interact():
			interaction.interact()
			if interaction.only_once:
				nearby_interactions.erase(interaction)
			return

func _on_interaction_zone_area_entered(area: Area2D) -> void:
	if area is Interactable:
		nearby_interactions.append(area)

func _on_interaction_zone_area_exitded(area: Area2D) -> void:
	if area is Interactable:
		nearby_interactions.erase(area)
		
func _play_movemement_animations():
	if not is_on_floor():
		if velocity.y > 0 and not player_sprite.animation.begins_with("fall"):
			_play_animation("fall")
		if velocity.y < 0 and not player_sprite.animation.begins_with("jump"):
			_play_animation("jump")
			if not jump_sound.playing:
				jump_sound.play()
	else:
		if velocity.x != 0:
			_play_animation("walk")
			if not walking_sound.playing:
				walking_sound.play()
		else:
			_play_animation("idle")
			walking_sound.stop()
			
func _play_animation(animation):
	var animation_identifier = animation + "_" + str(MaskManager.current_mask)
	player_sprite.play(animation_identifier)
	
func die():
	print("start death process")
	death_timer.start(death_animation_player.get_animation("death").length)
	death_animation_player.play("death")
	get_tree().paused = true
	
func _on_death_timer_timeout() -> void:
	get_tree().paused = false
	death_timer.stop()
	death_animation_player.play("RESET")
	print("game over, player died")
	CheckpointManager.return_to_last_checkout(self)
	

# Killzone interactions
func _on_killzone_detector_body_entered(body: Node2D) -> void:
	die()
	
