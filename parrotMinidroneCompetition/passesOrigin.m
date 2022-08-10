function result = passesOrigin(point1, point2, error)

    x1 = point1.x;
    x2 = point2.x;
    y1 = point1.y;
    y2 = point2.y;

    % Returns true if any point is close to the origin within the threshold
    origin.x = 0;
    origin.y = 0;
    if distance(point1, origin) < error || distance(point2, origin) < error
        result = true;
        return;
    end

    % Infinite gradient
    if x1 == x2
        % Returns true if the vertical line is close to the y-axis within the threshold
        if abs(x1) < error
            result = y1 > 0 && y2 < 0 || y1 < 0 && y2 > 0;
            return;
        end
    end

    % General case
    [gradient, intercept] = getLineEquationFromPoints(point1, point2);

    if intercept > error
        % Returns false if the intercept is too large
        result = false;
        return;
    else

        if abs(x1) < error
            x1 = 0;
        end
        if abs(x2) < error
            x2 = 0;
        end

        % Returns true if 0 \in [x1, x2]
        if (x1 <= 0 && x2 >= 0 && x1 ~= x2) || (x1 >= 0 && x2 <= 0 && x1 ~= x2)
            result = true;
        end

        % Otherwise, segment point1-point2 does not pass through (0,0)
        result = false;
    end
    
end 