extends Node

# Inventory items
var inventory = []

# Custom signal
signal inventory_updated
var spawnable_items = [
	{"type": "Consumable", "name": "Berry", "effect": "Health", "texture": preload("res://Assets/Icons/icon31.png")},
	{"type": "Consumable", "name": "Water", "effect": "Stamina", "texture": preload("res://Assets/Icons/icon9.png")},
	{"type": "Consumable", "name": "Mushroom", "effect": "Armor", "texture": preload("res://Assets/Icons/icon32.png")},
	{"type": "Gift", "name": "Gemstone", "effect": "", "texture": preload("res://Assets/Icons/icon21.png")},
]

# Scene and node references
var player_node: Node = null
@onready var inventory_slot_scene = preload("res://Scenes/inventory_slot.tscn")

# Hotbar items
var hotbar_size = 5
var hotbar_inventory = []


func _ready():
	# Initialize the inventory with 30 slots (spread over 9 blocks per row)
	inventory.resize(30)
	hotbar_inventory.resize(hotbar_size)


# Adds an item to the inventory, returns true if successful
func add_item(item, to_hotbar = false):
	var added_to_hotbar = false
	# Add to hotbar
	if to_hotbar:
		added_to_hotbar = add_hotbar_item(item)
		inventory_updated.emit()
	# Add to inventory
	if not added_to_hotbar:
		for i in range(inventory.size()):
			if inventory[i] != null \
			and inventory[i]["type"] == item["type"] \
			and inventory[i]["effect"] == item["effect"]:
				inventory[i]["quantity"] += item["quantity"]
				inventory_updated.emit()
				print("Item added", inventory)
				return true
			elif inventory[i] == null:
				inventory[i] = item
				inventory_updated.emit()
				print("Item added", inventory)
				return true
		return false


# Removes an item from the inventory based on type and effect
func remove_item(item_type, item_effect):
	for i in range(inventory.size()):
		if inventory[i] != null \
		and inventory[i]["type"] == item_type \
		and inventory[i]["effect"] == item_effect:
			inventory[i]["quantity"] -= 1
			if inventory[i]["quantity"] <= 0:
				inventory[i] = null
			inventory_updated.emit()
			return true
	return false


# Increase inventory size dynamically
func increase_inventory_size(extra_slots):
	inventory.resize(inventory.size() + extra_slots)
	inventory_updated.emit()


# Sets the player reference for inventory interactions
func set_player_reference(player):
	player_node = player


# Adjust the drop position to avoid overlapping with nearby items
func adjust_drop_position(position):
	var radius = 100
	var nearby_items = get_tree().get_nodes_in_group("Items")
	for item in nearby_items:
		if item.global_position.distance_to(position) < radius:
			var random_offset = Vector2(randf_range(-radius, radius), randf_range(-radius, radius))
			position += random_offset
			break
	return position


# Drops an item at a specified position, adjusting for nearby items
func drop_item(item_data, drop_position):
	var item_scene = load(item_data["scene_path"])
	var item_instance = item_scene.instantiate()
	item_instance.set_item_data(item_data)
	drop_position = adjust_drop_position(drop_position)
	item_instance.global_position = drop_position
	get_tree().current_scene.add_child(item_instance)


# Try adding to hotbar
func add_hotbar_item(item):
	for i in range(hotbar_size):
		if hotbar_inventory[i] == null:
			hotbar_inventory[i] = item
			return true
	return false


# Removes an item from the hotbar
func remove_hotbar_item(item_type, item_effect):
	for i in range(hotbar_inventory.size()):
		if hotbar_inventory[i] != null \
		and hotbar_inventory[i]["type"] == item_type \
		and hotbar_inventory[i]["effect"] == item_effect:
			if hotbar_inventory[i]["quantity"] <= 0:
				hotbar_inventory[i] = null
			inventory_updated.emit()
			return true
	return false


# Unassign hotbar item
func unassign_hotbar_item(item_type, item_effect):
	for i in range(hotbar_inventory.size()):
		if hotbar_inventory[i] != null \
		and hotbar_inventory[i]["type"] == item_type \
		and hotbar_inventory[i]["effect"] == item_effect:
			hotbar_inventory[i] = null
			inventory_updated.emit()
			return true
	return false


# Prevent duplicate item assignment
func is_item_assigned_to_hotbar(item_to_check):
	return item_to_check in hotbar_inventory


# Swap items in the inventory based on their indices
func swap_inventory_items(index1, index2):
	if index1 < 0 or index1 > inventory.size() \
	or index2 < 0 or index2 > inventory.size():
		return false

	var temp = inventory[index1]
	inventory[index1] = inventory[index2]
	inventory[index2] = temp

	inventory_updated.emit()
	return true


# Swap items in the hotbar based on their indices
func swap_hotbar_items(index1, index2):
	if index1 < 0 or index1 > hotbar_inventory.size() \
	or index2 < 0 or index2 > hotbar_inventory.size():
		return false

	var temp = hotbar_inventory[index1]
	hotbar_inventory[index1] = hotbar_inventory[index2]
	hotbar_inventory[index2] = temp

	inventory_updated.emit()
	return true