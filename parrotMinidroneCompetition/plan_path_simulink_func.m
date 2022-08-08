function [takeoff_complete, landing_ready, landing_zone_detected, target_x, target_y, target_z, motion_history] = plan_path_simulink_func(current_pos, vision_data, current_state, motion_history)
%PLAN_PATH_SIMULINK_FUNC Provides navigation point in traking stage and determines if the landing zone is detected
%
%   @param current_pos: structure that contains the current position, orientation, velocity and angular velocity of the minidrone.
%   @param vision_data: an array of breakpoint coordinates (pixel)
%   @param current_state:   enum value which represents the current state of the state machine.
%                           0: TakeOff, 1: Tracking, 2: ApproachingLandingSite, 3: Descending
%   @param motion_history: a 3x100 single array that store the positions in the past 0.5 second.
%


    % Record current motion
    x_history = motion_history(1,:);
    y_history = motion_history(2,:);
    z_history = motion_history(3,:);

    x_history = [current_pos.X, x_history(1:end - 1)];
    y_history = [current_pos.Y, y_history(1:end - 1)];
    z_history = [current_pos.Z, z_history(1:end - 1)];

    motion_history = cast([x_history;y_history;z_history], "double"); % Set data type for code generation

    % TODO: process vision data

    % TODO: convert pixel distance to metres using Pythagorus
    
    takeoff_complete = false;
    landing_ready = false;
    landing_zone_detected = false;
    target_x = 0;
    target_y = 1;
    target_z = 0;

end

