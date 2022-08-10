function point = getPointFromVisionData(vision_data, index)
    point.x = vision_data(1, index);
    point.y = vision_data(2, index);
    point.type = vision_data(3, index);
end