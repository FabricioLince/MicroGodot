extends Line2D

func draw_line_for_shape(shape:RectangleShape2D):
	var points = PoolVector2Array()
	points.append(Vector2.ZERO - shape.extents)
	points.append(Vector2(-shape.extents.x, shape.extents.y))
	points.append(Vector2.ZERO + shape.extents)
	points.append(Vector2(shape.extents.x, -shape.extents.y))
	draw_line_for_points(points)

func draw_line_for_polygon(polygon:Polygon2D):
	draw_line_for_points(polygon.polygon)

func draw_line_for_points(points:PoolVector2Array):
	clear_points()
	for i in range(points.size()):
		var sp = points[i]
		points[i] += Vector2(sign(sp.x)*5, sign(sp.y)*5)
		add_point(points[i])
	add_point(points[0])
