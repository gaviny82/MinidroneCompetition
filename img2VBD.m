function vision_data = img2VBD(filename)
    tic;
    
    % set up
    img = imread(filename); % must be RGB, 120*160 as in the size of photo captured 
    img_R = img(:,:,1);
    vision_data = zeros([3 11]);
    vision_data(3,:) = -1;
    
    redBW = imbinarize(img_R); % remove background if needed
    % redBW3 = bwskel(redBW); % doesn't work well due to branched endpoints
    redBW2 = bwmorph(redBW,"thin",6); % num of operations to be adjusted, edges to be solved
    redBW3 = bwmorph(redBW2,"skeleton",3);
    
    
    % Hough transform
    [H,theta,rho] = hough(redBW3);
    % houghMatViz(H,theta,rho)
    peaks = houghpeaks(H,10,"NHoodSize",[13,13]); % numpeaks to be adjusted
    lines = houghlines(redBW3,theta,rho,peaks);
    plotHoughLines(img,lines)
    
    
    % assume the first breakpoint is around y = 120
    points = lines;
    counter_edge=0;
    
    for i = 1:length(lines)
        xy = [lines(i).point1; lines(i).point2];
        [row,col] = find((xy<10)+(xy(:,1)>150)+(xy(:,2)>110));
        if ~isempty(row)
            % finding points at the edge
            if row == 1
                points(i).point1(3)=1;
                counter_edge = counter_edge + 1;
                    if counter_edge == 1 
                        vision_data(:,1) = transpose(points(i).point1);
                        starting_line_number = i;
                        starting_point_number = 0; % 0 means point1; 1 means point 2
                    end
            end
    
            if row == 2
                points(i).point2(3)=1;
                counter_edge = counter_edge + 1;
                    if counter_edge == 1 
                        vision_data(:,1) = transpose(points(i).point2);
                        starting_line_number = 1;
                    end
            end      
        end
    end
    
    % Label and arrange section points
    points = struct2cell(points);
    second_point = points{~starting_point_number+1,1,starting_line_number};
    counter = 1;
    
    while length(points) >= 1 && ~isempty(second_point)
    
        for i = 1:length(points(1,1,:)) % length won't change even after deleting one line
            point1 = points{1,1,i};
            point2 = points{2,1,i};
            distance1 = sqrt((point1(1)-second_point(1))^2 + (point1(2)-second_point(2))^2);
            distance2 = sqrt((point2(1)-second_point(1))^2 + (point2(2)-second_point(2))^2);
        
            if distance1 < 8
                counter = counter+1;
                points{1,1,i}(3) = 0;
                vision_data(:,counter) = transpose(points{1,1,i});
                second_point = points{2,1,i};
                points(:,:,i) = [];
                if length(points(1,1,:))==1 && length(lines) ~= 1 % in case there's only one line
                    second_point(3) = 2;
                    vision_data(:,counter+1) = transpose(second_point);
                    points(:,:,i) = [];
                end
                break
                
    
            elseif distance2 < 8
                counter = counter+1;
                points{2,1,i}(3) = 0;
                vision_data(:,counter) = transpose(points{2,1,i});
                second_point = points{1,1,i};
                points(:,:,i) = [];
                if length(points(1,1,:))==1 && length(lines) ~= 1 % in case there's only one line
                    second_point(3) = 2;
                    vision_data(:,counter+1) = transpose(second_point);
                    points(:,:,i) = [];
                end
                break
            end  
        end
    end
    


    % Find circular landing point (assume only one)
    [c,r] = imfindcircles(img_R, [10 25]);
    if ~isempty(c)
        c(3) = 3;
        vision_data(:,counter+2) = transpose(c);
    end



    % Calculate how much time elapsed while running the program
    disp("Time Elapsed: " + num2str(toc));
    
    function houghMatViz(H,T,R)
        % Convert the hough matrix to a grayscale image
        Hgray = mat2gray(H);
        % Enhance its brightness
        Hgray = imadjust(Hgray);
        % Display the hough transform
        imagesc(Hgray,"XData",T,"YData",R) 
        % Assign a colormap for the image
        colormap(hot)
        title("Hough Transform")
        % Add x-y labels
        xlabel("\theta")
        ylabel("\rho")
    end
    
    function plotHoughLines(image, lines)
        % Show the image
        imshow(image)
        % Plot the hough transform lines
        hold on    
        numLines = length(lines);
        for k = 1:numLines
            xy = [lines(k).point1; lines(k).point2];
            plot(xy(:,1),xy(:,2),"LineWidth",2,"Color","blue",...
                "Marker", "x", "MarkerEdgeColor", "g")
        end
        hold off
    end
end
