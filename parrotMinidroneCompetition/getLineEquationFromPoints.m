function [gradient, intercept] = getLineEquationFromPoints(point1, point2)

    gradient = (point1.y - point2.y) / (point1.x - point2.x);
    intercept = point1.y - gradient * point1.x;

end