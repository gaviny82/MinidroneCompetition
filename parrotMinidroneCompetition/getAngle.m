% Returns the angle (rad) from the positive x-axis of a position vector [x;y] in Cartesian coordinates
function angle = getAngle(x, y)

    if x == 0 
        if y == 0
            angle = 0;
            return;
        elseif y > 0
            angle = pi / 2;
            return;
        elseif y < 0
            angle = -pi / 2;
            return;
        end
    end

    angle = cast(atan(y / x), "double");
    if x < 0
        if y >= 0
            angle = angle + pi / 2;
        else % y < 0
            angle = angle - pi / 2;
        end
    end
end