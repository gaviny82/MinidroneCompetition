function point = getPointFromVisionData(vision_data, index)
    point.x = vision_data(index, 1);
    point.y = vision_data(index, 2);
    point.type = vision_data(index, 3);
end