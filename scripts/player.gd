extends CharacterBody2D

class_name Player

@export var max_hp = 10
var hp = 10


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var nearby_interactions: Array[Interactable] = []

func _physics_process(delta: float) -> void:
	_handle_movement(delta)
	_handle_interactions_input()
	
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
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
# Interactions
func _handle_interactions_input():
	if Input.is_action_just_pressed("interact"):
		_try_interact()

func _try_interact():
	if not nearby_interactions:
		return
	var interaction = nearby_interactions.get(0)
	interaction.interact()
	if interaction.only_once:
		nearby_interactions.erase(interaction)
	

func _on_interaction_zone_area_entered(area: Area2D) -> void:
	#if area is Interactable:
		nearby_interactions.append(area)

func _on_interaction_zone_area_exited(area: Area2D) -> void:
	if area is Interactable:
		nearby_interactions.erase(area)
