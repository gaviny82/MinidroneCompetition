%PLAN_PATH_SIMULINK_FUNC Provides navigation point in traking stage and determines if the landing zone is detected
%
%   @param current_pos: structure that contains the current position, orientation, velocity and angular velocity of the minidrone.
%   @param vision_data: a 3x11 array of breakpoint coordinates (pixel) and types.
%                       Each column represents a breakpoint, which has x in the first row, y in the second row and type in the third row.
%   @param current_state:   enum value which represents the current state of the state machine.
%                           0: TakeOff, 1: Tracking, 2: ApproachingLandingSite, 3: Descending
%   @param motion_history: a 3x100 single array that store the positions in the past 0.5 second.
%

function [takeoff_complete, landing_ready, landing_zone_detected, target_x, target_y, target_z, motion_history] = plan_path_simulink_func(current_pos, vision_data, current_state, motion_history)
    
    % Default return values
    target_x = 0;
    target_y = 0;
    target_z = -1.1;
    takeoff_complete = false;
    landing_zone_detected = false;
    landing_ready = false;

    % Record current motion
    x_history = motion_history(1,:);
    y_history = motion_history(2,:);
    z_history = motion_history(3,:);

    x_history = [current_pos.X, x_history(1:end - 1)];
    y_history = [current_pos.Y, y_history(1:end - 1)];
    z_history = [current_pos.Z, z_history(1:end - 1)];

    motion_history = cast([x_history;y_history;z_history], "double"); % Set data type for code generation

    PIXEL_ERROR_ALLOWED = 3; % Error allowed for which pixels are considered to be coincident
    HEIGHT_THRESHOLD = 1.0;
    HEIGHT_VAR_THRESHOLD = 0.1;             % TODO: to be adjusted
    APPROACH_DISTANCE_THRESHOLD = 0.001;    % in metres TODO: to be adjusted
    APPROACH_DISTANCE_VAR_THRESHOLD = 0.0001;    % TODO: to be adjusted
    LANDING_HEIGHT_THRESHOLD = 0.1;         % TODO: to be adjusted based on min height that the sensor can detect
    LANDING_HEIGHT_VAR_THRESHOLD = 0.001;   % TODO: to be adjusted
    ANGLE_THRESHOLD = 0.087266;            % 5 deg

    if current_state == 0 % Takeoff

        target_x = 0;
        target_y = 0;
        target_z = -1.1;

        takeoff_complete = var(z_history) < HEIGHT_VAR_THRESHOLD && all(abs(z_history) > HEIGHT_THRESHOLD);

        landing_ready = false;
        landing_zone_detected = false;

    elseif current_state == 1 % Tracking

        flag = false; % Set to true when at the turning point

        pointA = getPointFromVisionData(vision_data, 1);
        pointB = getPointFromVisionData(vision_data, 1);

        disp("Vision data:")
        disp(vision_data)

        for k = 1:10
            point1 = getPointFromVisionData(vision_data, k);
            point2 = getPointFromVisionData(vision_data, k + 1);
            % TODO: Stop the loop if next point does not exist by checking point2.type == -1 (use -1 to indicate the element in the array is not used)

            if passesOrigin(point1, point2, PIXEL_ERROR_ALLOWED)

                % Segment between point1 to point2 passes the centre of image
                pointA = point1;
                pointB = point2;

                if k <= 9 % check the next segment
                    point3 = getPointFromVisionData(vision_data, k + 2);
                    if passesOrigin(point2, point3, PIXEL_ERROR_ALLOWED)
                        % Point2 is the turning point, ignored
                        pointB = point3;
                        flag = true;
                    end
                end
                break;

            end
        end

        disp(pointA)
        disp(pointB)

        % Select either pointA or pointB based on current flight direction
        % Eliminate the one in the direction in which the minidrone is travelling.
        theta_current = getAngle(current_pos.dx, current_pos.dy);
        thetaA = getAngle(pointA.x, pointA.y);
        thetaB = getAngle(pointB.x, pointB.y);

        % Reverse current direction
        if theta_current <= 0
            theta_current = theta_current + pi;
        else
            theta_current = theta_current - pi;
        end

        % If the reversed current direction is in the same direction as pointA
        if abs(thetaA - (theta_current)) < ANGLE_THRESHOLD
            pointNext = pointB;
        else
            pointNext = pointA;
        end

        landing_zone_detected = pointNext.type == 2;

        takeoff_complete = true;
        landing_ready = false;

    elseif current_state == 2 % Approaching landing site.

        landing_zone.x = 0;
        landing_zone.y = 0;
        landing_zone.type = -1;

        % Find landing zone coordinates by iterating through vision_data and find the one with type == 2
        for k = 1:11
            if vision_data(3, k) == 2
                landing_zone = getPointFromVisionData(vision_data, k);
                break;
            end
        end

        % landing zone lost
        if landing_zone.type == -1
            takeoff_complete = true;
            landing_zone_detected = false;
            landing_ready = false;
            disp("[ERROR]: Landing zone lost.")
            return;
        end
                
        % The minidrone approaches the landing zone at constant height and the horizontal distance is calculated:
        target_x = cast(pixel2metres(landing_zone.x, abs(current_pos.Z)) + current_pos.X, "double");
        target_y = cast(pixel2metres(landing_zone.y, abs(current_pos.Z)) + current_pos.Y, "double");
        target_z = -1.1;
        
        % Calculate the distance to the landing zone in the past 0.5 second.
        % If all distances is within APPROACH_DISTANCE_THRESHOLD and Var(distances) < APPROACH_DISTANCE_VAR_THRESHOLD, landing is ready.
        distances = sqrt((x_history - target_x).^2 + (y_history - target_y).^2);

        landing_ready = var(distances) < APPROACH_DISTANCE_VAR_THRESHOLD && all(distances < APPROACH_DISTANCE_THRESHOLD);
        
        takeoff_complete = true;
        landing_zone_detected = true;

    elseif current_state == 3 % Descending

        % TODO: 
        % - the height is slowly decreased until ground is reached (z = 0).
        % - set target_z directly to zero if height < HEIGHT_VAR_THRESHOLD
        target_x = cast(current_pos.X, "double");
        target_y = cast(current_pos.Y, "double");
        target_z = cast(current_pos.Z + 0.0005, "double");
        
        takeoff_complete = true;
        landing_zone_detected = true;
        landing_ready = true;

    else
        disp("[ERROR] Invalid state " + current_state)
    end

end
