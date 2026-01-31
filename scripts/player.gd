extends CharacterBody2D

class_name Player

@export var max_hp = 10
var hp = 10


@onready var player_sprite: AnimatedSprite2D = $Future
@onready var item_sprite: Sprite2D = $Future/ItemSprite

const SPEED = 100.0
const JUMP_VELOCITY = -200.0
const ITEM_SHIFT = 7


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
	
func _process(delta: float) -> void:
	_play_movemement_animations()
	
func _handle_movement(delta: float):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

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
	
