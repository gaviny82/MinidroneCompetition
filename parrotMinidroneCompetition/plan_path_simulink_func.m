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
    target_x = cast(current_pos.X, "double");
    target_y = cast(current_pos.Y, "double");
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
    LANDING_HEIGHT_THRESHOLD = 0.15;         % TODO: to be adjusted based on min height that the sensor can detect
    ANGLE_THRESHOLD = 0.087266;             % 5 deg
    MAX_MOVE_STEP = 0.2;
    HORIZONTAL_VELOCITY_THRESHOLD = 0.05;

    landing_zone.x = cast(current_pos.X, "double");
    landing_zone.y = cast(current_pos.Y, "double");
    landing_zone.type = 3;

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

            % Exit loop if next point does not exist
            if point1.type == -1 || point2.type == -1
                break;
            end

            if passesOrigin(point1, point2, PIXEL_ERROR_ALLOWED)

                % Segment between point1 to point2 passes the centre of image
                pointA = point1;
                pointB = point2;

                if k <= 9 % check the next segment
                    point3 = getPointFromVisionData(vision_data, k + 2);
                    
                    if point3.type == -1
                        break;
                    end

                    % Landing zone detected
                    if point3.type == 3
                        % Set flags and return immediately
                        landing_zone_detected = true;
                        takeoff_complete = true;
                        landing_ready = false;

                        return;
                    end
                    
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
        theta_current = getAngle(current_pos.dx, current_pos.dy, 0);
        thetaA = getAngle(pointA.x, pointA.y, PIXEL_ERROR_ALLOWED);
        thetaB = getAngle(pointB.x, pointB.y, PIXEL_ERROR_ALLOWED);

        horizontal_velocity = sqrt(current_pos.dx^2 + current_pos.dy^2); % This is used to determine if the minidrone has just taken off, or it is at the end of track

        if thetaA == 0 && pointA.type == 2 && horizontal_velocity < HORIZONTAL_VELOCITY_THRESHOLD      % This happens immediately after takeoff is complete
            pointNext = pointB;
        elseif thetaB == 0 && pointB.type == 2 && horizontal_velocity < HORIZONTAL_VELOCITY_THRESHOLD  % This happens immediately after takeoff is complete
            pointNext = pointA;
        else % General case: any time other than takeoff
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
        end

        % Assign target_x,y,z
        % Note: y-direction on the image is x-direction of the minidrone.
        target_x_tmp = pixel2metres(pointNext.y, abs(current_pos.Z)) + current_pos.X;
        if target_x_tmp > current_pos.X + MAX_MOVE_STEP
            target_x = cast(current_pos.X + MAX_MOVE_STEP * sign(target_x_tmp), "double");
        else
            target_x = cast(target_x_tmp, "double");
        end

        target_y_tmp = pixel2metres(pointNext.x, abs(current_pos.Z)) + current_pos.Y;
        if abs(target_y_tmp - current_pos.Y) > MAX_MOVE_STEP
            target_y = cast(current_pos.Y + MAX_MOVE_STEP * sign(target_y_tmp), "double");
        else
            target_y = cast(target_y_tmp, "double");
        end
        
        target_z = -1.1;

        % Assign flags
        landing_zone_detected = false;
        takeoff_complete = true;
        landing_ready = false;

    elseif current_state == 2 % Approaching landing site.

        landing_zone_detected = false;

        % Find landing zone coordinates by iterating through vision_data and find the one with type == 2
        for k = 1:11
            if vision_data(3, k) == 3
                landing_zone = getPointFromVisionData(vision_data, k);
                landing_zone_detected = true;
                break;
            end
        end

        % landing zone lost
        if ~landing_zone_detected
            takeoff_complete = true;
            landing_zone_detected = false;
            landing_ready = false;
            disp("[ERROR]: Landing zone lost.")
            return;
        end
                
        % The minidrone approaches the landing zone at constant height and the horizontal distance is calculated:
        % Note: y-direction on the image is x-direction of the minidrone.
        target_x = cast(pixel2metres(landing_zone.y, abs(current_pos.Z)) + current_pos.X, "double");
        target_y = cast(pixel2metres(landing_zone.x, abs(current_pos.Z)) + current_pos.Y, "double");
        target_z = -1.1;
        
        % Calculate the distance to the landing zone in the past 0.5 second.
        % If all distances is within APPROACH_DISTANCE_THRESHOLD and Var(distances) < APPROACH_DISTANCE_VAR_THRESHOLD, landing is ready.
        distances = sqrt((x_history - target_x).^2 + (y_history - target_y).^2);

        landing_ready = var(distances) < APPROACH_DISTANCE_VAR_THRESHOLD && all(distances < APPROACH_DISTANCE_THRESHOLD);
        
        takeoff_complete = true;
        landing_zone_detected = true;

    elseif current_state == 3 % Descending

        % The height is slowly decreased until ground is reached (z = 0).
        target_x = cast(x_history(1), "double");
        target_y = cast(y_history(1), "double");
        target_z = cast(current_pos.Z + 0.0005, "double");
        
        if abs(target_z) < HEIGHT_THRESHOLD
            target_z = 0;
        end

        takeoff_complete = true;
        landing_zone_detected = true;
        landing_ready = true;

    else
        disp("[ERROR] Invalid state " + current_state)
    end

end
