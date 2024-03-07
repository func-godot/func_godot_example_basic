@tool
class_name Actor
extends CharacterBody3D

enum ActorFlags {
	PLAYER = 1,
	BIG_FRIEND = 2,
	ATTENTIVE_FRIEND = 4,
	HAPPY_FRIEND = 8
}
@export var flags: int = 0
@export var targetname: String

enum ActorStates {
	NORMAL = 0,
	SCRIPTED = 1
}
var current_state: int = ActorStates.NORMAL

var on_floor: bool = false

var move_input: Vector3 = Vector3.ZERO
var speed: float = 3.0
var jump_strength: float = 5.0
const GRAVITY: float = 10.0
var anim_player: AnimationPlayer

func _func_godot_apply_properties(props: Dictionary) -> void:
	add_to_group(props["classname"] as String)
	flags = props["flags"] as int
	if flags & ActorFlags.BIG_FRIEND:
		scale *= 2

func turn_towards_pos(tgt_pos: Vector3) -> void:
	var b: Basis = global_transform.basis
	tgt_pos -= global_position
	var tgt_dir: Vector3 = tgt_pos - tgt_pos.project(b.y)
	tgt_dir = tgt_dir.normalized()
	b.y = b.y.normalized()
	
	var rot_amount: float = -b.z.dot(tgt_dir)
	if rot_amount > 0.999:
		return
	if rot_amount <= -1.0:
		rot_amount = PI
	else:
		rot_amount = acos(rot_amount)
	rot_amount *= sign(-b.z.rotated(b.y, 1.570796).dot(tgt_dir))
	rotate(b.y, rot_amount)

func _init() -> void:
	collision_layer = GameManager.ACTOR_LAYER + GameManager.TRIGGER_LAYER
	collision_mask = GameManager.WORLD_LAYER + GameManager.TRIGGER_LAYER

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	if flags & ActorFlags.PLAYER:
		add_to_group("PLAYER")
	GAME.set_targetname(self, targetname)

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if flags & ActorFlags.PLAYER:
		move_input.z = Input.get_axis("ui_up", "ui_down")
		move_input.x = Input.get_axis("ui_right", "ui_left")
		move_input.y = float(Input.is_action_just_pressed("ui_accept"))

func _physics_process(delta) -> void:
	if Engine.is_editor_hint():
		return
	
	var current_fall_speed: float = velocity.y
	if on_floor:
		current_fall_speed = move_input.y * jump_strength
	current_fall_speed -= GRAVITY * delta
	velocity = global_transform.basis.z * move_input.z * speed
	velocity.y += current_fall_speed
	rotate_y(PI * move_input.x * delta)
	move_and_slide()
	on_floor = is_on_floor()
	
	if (flags & ActorFlags.ATTENTIVE_FRIEND) and not (flags & ActorFlags.PLAYER):
		var players: Array[Node] = get_tree().get_nodes_in_group("PLAYER")
		for pl in players:
			if pl is Actor:
				turn_towards_pos(pl.global_position)
				break
