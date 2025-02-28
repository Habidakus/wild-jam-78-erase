class_name SkillGraphic extends Control

var margin : MarginContainer
var background : ColorRect
var skill : SkillStats
const our_scene : Resource = preload("res://Scenes/card_graphic.tscn")

func init(_skill : SkillStats, unit : UnitStats) -> void:
	skill = _skill
	(find_child("SkillName") as Label).text = skill.skill_name
	(find_child("HeroName") as Label).text = unit.unit_name
	(find_child("LevelValue") as Label).text = str(skill.current_level)
	(find_child("Description") as RichTextLabel).text = str(skill.generate_description())
	(find_child("Sprite2D") as Sprite2D).texture = unit.get_texture()

func _ready() -> void:
	margin = find_child("MarginContainer") as MarginContainer
	background = find_child("Background") as ColorRect

func _process(_delta: float) -> void:
	background.size = margin.size
