@tool
class_name Marsfrog
extends Actor

func use() -> void:
	current_state = ActorStates.SCRIPTED
	if randi() % 2:
		anim_player.play("pain0")
	else:
		anim_player.play("pain1")

func _anim_finished(_anim: StringName) -> void:
	if current_state == ActorStates.SCRIPTED:
		current_state = ActorStates.NORMAL

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	super._ready()
	anim_player = $marsfrog/AnimationPlayer
	anim_player.connect("animation_finished", _anim_finished)
	if flags & ActorFlags.HAPPY_FRIEND:
		current_state = ActorStates.SCRIPTED
		anim_player.play("walk")

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	super._process(delta)
	if current_state == ActorStates.NORMAL:
		if on_floor:
			if move_input.z != 0:
				anim_player.play("run")
			elif move_input.x != 0:
				anim_player.play("walk")
			else:
				anim_player.play("stand")
		else:
			anim_player.play("attack")
