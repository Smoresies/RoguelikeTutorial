class_name DropItemAction
extends ItemAction

# If we attempt to drop an item...
func perform() -> bool:
	# if there is no item then just return we failed
	if item == null:
		return false
	# Otherwise drop from inventory and return true
	entity.inventory_component.drop(item)
	return true
