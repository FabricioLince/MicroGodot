extends Node2D

export (float) var min_height = 0

func set_size(new_size):
	#print("setting size for %s = %s"%[description(), str(new_size)])
	new_size.y = max(new_size.y, min_height)
	$NinePatchRect.rect_size = new_size
	$NinePatchRect.margin_left = new_size.x/-2
	$NinePatchRect.margin_right = new_size.x/2
	$NinePatchRect.margin_top = new_size.y/-2
	$NinePatchRect.margin_bottom = new_size.y/2
	
	$Sprite.region_rect.size = new_size - Vector2(4,6)
