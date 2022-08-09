function [takeoff_complete, landing_ready, landing_zone_detected, target_x, target_y, target_z, motion_history] = plan_path_simulink_func(current_pos, vision_data, motion_history)
%PLAN_PATH_SIMULINK_FUNC Provides navigation point in traking stage and determines if the landing zone is detected

    % Record current motion
    x_history = motion_history(1,:);
    y_history = motion_history(2,:);
    z_history = motion_history(3,:);

    x_history = [current_pos.X, x_history(1:end - 1)];
    y_history = [current_pos.Y, y_history(1:end - 1)];
    z_history = [current_pos.Z, z_history(1:end - 1)];

    motion_history = cast([x_history;y_history;z_history], "double"); % Set data type for code generation

    % TODO: process vision data
    takeoff_complete = false;
    landing_ready = false;
    landing_zone_detected = false;

    % ALL vision_data COORDINATES ARE BASED ON CAMERA VIEW'S COORDINATE
    % SYSTEM, WHERE THE MINIDRONE IS ALWAYS AT THE ORIGIN

    % Convert the vision_data coordinates from pixel units to simulation
    % background units (in meters)
    % Every pixel corresponds to 0.005*abs(current_pos.Z) meter per pixel
    perPxl = 0.005*abs(current_pos.Z);
    
    xRel = vision_data.x*perPxl;
    yRel = vision_data.y*perPxl;

    Err = 3*perPxl; % Set error allowed in simulation background units (used later)

    % Transform the relative coordinates from the camera view to the
    % simulation background coordinates
    xP = xRel + current_pos.X;
    yP = yRel + current_pos.Y;
    
    % Examine if the breakpoints stored as vision_data contain any turning 
    % point (type = 0) that is an intersection of two segments of tracks. Find the
    % turning point coordinates (xT, yT)

    for i = 1:length(vision_data.type)
        
        if vision_data.type(i) == 0

            xT = xP(i);
            yT = yP(i);

            % If there is a turning point, turnPt = 1
            turnPt = 1;

        end
    end

    % If the minidrone is already above the turning point or has gone past 
    % the turning point, head to the edge of the camera view, else the
    % minidrone should go to the turning point
    if any(abs(x_history(:) - xT) < Err) && any(abs(y_history(:) - yT) < Err)

        % Follow the line to go the edge of view in the current direction
        for k = 1:length(xRel)

            % Go to the coordinate if the minidrone has not been there
            if any(abs(x_history(:) - xP(k)) > Err) || any(abs(y_history(:) - yP(k)) > Err)
                target_x = xP(k);
                target_y = yP(k);
                break
            end
        end

    else

        % Else set the turning point as target

        target_x = xT;
        target_y = yT;
    end
end

