class_name OrcComponent
extends FighterComponent

func _init(definition: OrcComponentDefinition) -> void:
	super._init(definition)
	
	# Used to change name if they are adjusted
	var _base_power = base_power
	var _base_defense = base_defense
	var _base_hp = max_hp
	
	
	max_hp += randi_range(-definition.hpDif, definition.hpDif)
	hp = max_hp
	base_power += randi_range(-definition.powerDif, definition.powerDif)
	base_defense += randi_range(-definition.defenseDif, definition.defenseDif)
	
	await ready
	if _base_hp != max_hp:
		# Lower Normal HP
		if _base_hp > max_hp:
			entity.entity_name = "%s %s" % ["Frail", entity.entity_name]
		else:
			entity.entity_name = "%s %s" % ["Hearty", entity.entity_name]
	
	if _base_power != base_power:
		if _base_power > base_power:
			entity.entity_name = "%s %s" % ["Wimpy", entity.entity_name]
		else:
			entity.entity_name = "%s %s" % ["Strong", entity.entity_name]
	
	if _base_defense != base_defense:
		if _base_defense > base_defense:
			entity.entity_name = "%s %s" % ["Fragile", entity.entity_name]
		else:
			entity.entity_name = "%s %s" % ["Tough", entity.entity_name]
	
	print(entity.entity_name)
