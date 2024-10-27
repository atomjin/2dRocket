extends Control

# Drag each star texture from the scene tree to these variables in the editor
@onready var star1: TextureRect = $RatStage/BlankStar/Star1
@onready var star2: TextureRect = $RatStage/BlankStar/Star2
@onready var star3: TextureRect = $RatStage/BlankStar/Star3

# Textures for the star states
@onready var empty_star_texture: Texture2D
@onready var yellow_star_texture: Texture2D

# Function to update stars based on conditions
func update_stars(condition1: bool, condition2: bool, condition3: bool) -> void:
	star1.texture = yellow_star_texture if condition1 else empty_star_texture
	star2.texture = yellow_star_texture if condition2 else empty_star_texture
	star3.texture = yellow_star_texture if condition3 else empty_star_texture
