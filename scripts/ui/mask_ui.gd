extends Panel

@export var hasPastMask: bool
@export var hasFutureMask: bool
@onready var past_mask: TextureRect = $PastMask
@onready var no_mask: TextureRect = $NoMask
@onready var future_mask: TextureRect = $FutureMask


func _draw() -> void:
	past_mask.visible = hasPastMask
	future_mask.visible = hasFutureMask


func _on_ready() -> void:
	MaskManager.mask_changed.connect(onMaskChanged)
	

func onMaskChanged(previousMask: MaskManager.MASK, currentMask: MaskManager.MASK):
	match currentMask:
		0:
			(past_mask.material as ShaderMaterial).set_shader_parameter("outline_color", Color.WHITE)
		1:
			(no_mask.material as ShaderMaterial).set_shader_parameter("outline_color", Color.WHITE)
		2:
			(future_mask.material as ShaderMaterial).set_shader_parameter("outline_color", Color.WHITE)
	
	if currentMask != previousMask:
		match previousMask:
			0:
				(past_mask.material as ShaderMaterial).set_shader_parameter("outline_color", Color.TRANSPARENT)
			1:
				(no_mask.material as ShaderMaterial).set_shader_parameter("outline_color", Color.TRANSPARENT)
			2:
				(future_mask.material as ShaderMaterial).set_shader_parameter("outline_color", Color.TRANSPARENT)
