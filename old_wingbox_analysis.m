% DP 2.5
% Raymann Singh
% GUI Attempt
% Init
clear, clc, close all
%%
wingbox_GUI

%% 
function wingbox_GUI()
    % Create the main GUI figure without menu and toolbars
    fig = figure('Name', 'Wingbox GUI', 'NumberTitle', 'off', ...
                 'Position', [100, 100, 800, 600], 'Resize', 'off', ...
                 'MenuBar', 'none', 'ToolBar', 'none');
    
    tabGroup = uitabgroup(fig, 'Position', [0, 0, 1, 1]); % Tab group at the top
    tab1 = uitab(tabGroup, 'Title', 'Geometry');  % First tab
    tab2 = uitab(tabGroup, 'Title', 'Distribution'); % Second tab

    tab1Panel = uipanel(fig, 'Parent', tab1, 'Position', [0, 0, 1, 1]);
    tab2Panel = uipanel(fig, 'Parent', tab2, 'Position', [0, 0, 1, 1]);

    % Parameters
    initialValuesGeo = [6, 5, 24, 0.5, 0.5, 18*12, 3]'; 
    initialDataGeo = num2cell(initialValuesGeo); 
    assignin('base', 'geo', initialDataGeo);
    designParamsGeo = {'LeadingEdge Height', 'TrailingEdge Height', ...
        'Chord', 'TopSweep Height', 'Taper Ratio', ...
        'Wing Span (in)', '# of Boxes'};

    initialValuesDist = [200, 100, 3, 1.05, 0.5, 0.5]';
    initialDataDist = num2cell(initialValuesDist);
    assignin('base', 'dist', initialDataDist);
    designParamsDist = {'Fuselage Weight', 'Wing Structural Weight', ...
        'Load Factor', 'Wing Lift Ratio', 'Lift at Tip Ratio', 'Weight at Tip Ratio'};

    % Set the width and height of the table dynamically based on the data
    numRows = numel(designParamsGeo);
    rowHeight = 25.7;  % Height of each row (you can adjust this value)
    tableHeight = numRows * rowHeight;  % Total height based on the number of rows
    tableWidth = 200;  % Width of the table (you can adjust this value)
    
    numRows_dist = numel(designParamsDist);
    rowHeight_dist = 28;
    tableHeight_dist = numRows_dist*rowHeight_dist;
    tableWidth_dist = 250;
    
    % Create the table with editable cells
    uitGeometry = uitable(tab1Panel, 'Position', [50, 300, tableWidth, tableHeight], ...
                  'Data', initialDataGeo, ...
                  'ColumnName', {'Geometry'}, ...
                  'RowName', designParamsGeo, ...
                  'ColumnEditable', true(1,1), ... % Make cells editable
                  'CellEditCallback', @(src, event) updateValuesGeo(src, fig));

    % Plots
    % Full wing
    ax1 = axes('Parent', tab1Panel, 'Position', [0.4, 0.6625, 0.35, 0.2]);
    plotWing(ax1, initialValuesGeo);

    % Root 2D - Geo
    ax2 = axes('Parent', tab1Panel, 'Position', [0.4, 0.3, 0.35, 0.2]);    
    plotWingbox(ax2, initialValuesGeo, 'chord')

    % Root 2D - Dist
        %                               replace with new updateDist()
    ax3 = axes('Parent', tab2Panel, 'Position', [0.5, 0.475, 0.35, 0.4]);    
    plotWingbox(ax3, initialValuesGeo, 'span')

    % Store axes handles in the figure's UserData
    fig.UserData.ax1 = ax1;
    fig.UserData.ax2 = ax2;
    fig.UserData.ax3 = ax3;

    % Distribution Tab Content
    uitDist = uitable(tab2Panel, 'Position', [50, 300, tableWidth_dist, tableHeight_dist], ...
              'Data', initialDataDist, ...
              'ColumnName', {'Forces'}, ...
              'RowName', designParamsDist, ...
              'ColumnEditable', true(1,1), ... % Make cells editable
              'CellEditCallback', @(src, event) updateValuesDist(src, fig));

        % Create buttons for Lift and Weight selection
    uicontrol(tab2Panel, 'Style', 'text', 'String', 'Lift', 'Position', [50, 250, 60, 20], 'FontWeight', 'bold');
    liftLinearBtn = uicontrol(tab2Panel, 'Style', 'pushbutton', 'String', 'Linear', 'Position', [50, 210, 60, 30], ...
              'Callback', @(src, event) updateDist(src, fig, 'lift.linear'));
    uicontrol(tab2Panel, 'Style', 'pushbutton', 'String', 'Parabolic', 'Position', [50, 170, 60, 30], ...
              'Callback', @(src, event) updateDist(src, fig, 'lift.parabolic'));

    uicontrol(tab2Panel, 'Style', 'text', 'String', 'Weight', 'Position', [50, 120, 60, 20], 'FontWeight', 'bold');
    weightLinearBtn = uicontrol(tab2Panel, 'Style', 'pushbutton', 'String', 'Linear', 'Position', [50, 80, 60, 30], ...
              'Callback', @(src, event) updateDist(src, fig, 'weight.linear'));
    uicontrol(tab2Panel, 'Style', 'pushbutton', 'String', 'Parabolic', 'Position', [50, 40, 60, 30], ...
              'Callback', @(src, event) updateDist(src, fig, 'weight.parabolic'));
end

% Callback function to automatically update the values from the uitable
function updateValuesGeo(uitable, fig)
    % Get the updated data from the table
    data = get(uitable, 'Data');                                % Add in input valiation for negatives
    assignin('base', 'geo', data);

    % Update the wingbox plot with the new data
    ax1 = fig.UserData.ax1; % Full wing axes
    ax2 = fig.UserData.ax2; % Root 2D axes
    ax3 = fig.UserData.ax3; % Root 2D axes - Dist
    plotWing(ax1, cell2mat(data)); % Update the plot with new values
    plotWingbox(ax2, cell2mat(data), 'chord');
    plotWingbox(ax3, cell2mat(data), 'chord');


                            % Fetch error if TE > LE or goes below 0
end

function updateValuesDist(src, fig)
    % Get the updated data from the table
    dataDist = src.Data;
    assignin('base', 'dist', dataDist);                         % Add in input validation for negatives
    

    % Update the wingbox plot with the new data
    ax2 = fig.UserData.ax2; % Root 2D axes - Geo
end

function updateDist(src, fig, type)
    dataGeo = evalin('base', 'geo');
    dataDist = evalin('base', 'dist');
    ax3 = fig.UserData.ax3; % Root 2D axes - Dist
    liftDistribution(ax3, cell2mat(dataGeo), cell2mat(dataDist), type);
end

function liftDistribution(ax, paramsGeo, paramsDist, type)
    W_fuselage = paramsDist(1);
    W_wing = paramsDist(2);
    n = paramsDist(3);
    wingLiftRatio = paramsDist(4); 
    liftTipRatio = paramsDist(5);
    weightTipRatio = paramsDist(6);

    leadingEdgeHeight = paramsGeo(1);
    chord = paramsGeo(3);
    topSweepHeight = paramsGeo(4);
    wingSpan = paramsGeo(6);

    W = W_fuselage + 2*W_wing;
    L_wing = W*n*wingLiftRatio/2;
    x = linspace(0, wingSpan, 100);            

    l_root = 2*L_wing/(wingSpan*(1 + liftTipRatio));
    l_tip = liftTipRatio*l_root;

    w_root = 2*W_wing/(wingSpan*(1 + weightTipRatio));
    w_tip = weightTipRatio*w_root;
    
    
    cla(ax);
    plotWingbox(ax, paramsGeo, 'span');     % Change to spanwise
    hold(ax, 'on')
    axis(ax, 'on')
    ylim(ax, [-4 10])
    start_height_lift = leadingEdgeHeight;
    end_height_lift = (leadingEdgeHeight-topSweepHeight)*1.5;
    start_height_weight = -0.5*leadingEdgeHeight; 
    end_height_weight = -0.25*leadingEdgeHeight; 

    SF = 10; % Scaling Factor
    switch type
                        % Need to scale graph properly
                        % fix graphs    
                            % axis off + arrows + color?
                        % fix scaling
                            % should auto scale on tab init (this is
                            % b/c of earlier call on ax3, that should be
                            % changed to this function)
                        % fix hold on
                            % should be both lift + weight
        case 'lift.linear'
            linear_lift = (l_tip - l_root)/wingSpan * x + l_root;
            linear_lift_plot = (l_tip - l_root)/wingSpan * x * SF + l_root ...
                + start_height_lift;
            plot(ax, x, linear_lift_plot, 'LineWidth', 2);
            ylim(ax, [-4 max(linear_lift_plot)+1])
        case 'lift.parabolic'
            lift_parabolic = (x - wingSpan).^2/(wingSpan^2/l_tip) + l_tip; 
            parabolic_lift_plot = (lift_parabolic - min(lift_parabolic)) / ...
                (max(lift_parabolic) - min(lift_parabolic)) * ...
                (start_height_lift - end_height_lift) + end_height_lift;
            plot(ax, x, lift_parabolic, 'LineWidth', 2);

        case 'weight.linear'
            linear_weight = (w_tip - w_root)/wingSpan * x + w_root;
            linear_weight_plot = (linear_weight - min(linear_weight)) / ...
                (max(linear_weight) - min(linear_weight)) * ...
                (start_height_weight - end_height_weight) + end_height_weight;
            plot(ax, x, linear_weight_plot, 'LineWidth', 2);
        case 'weight.parabolic'
            weight_parabolic = (x - wingSpan).^2/(wingSpan^2/w_tip) + w_tip;
            parabolic_weight_plot = (weight_parabolic - min(weight_parabolic)) / ...
                (max(weight_parabolic) - min(weight_parabolic)) * ...
                (start_height_weight - end_height_weight) + end_height_weight;
            plot(ax, x, parabolic_weight_plot, 'LineWidth', 2);
        otherwise
            error('Unknown type: %s', type);
    end
    % plot vert lines
    hold(ax, 'off')
end









% Function to plot the wingbox
function plotWing(ax, params)
    % Extract the parameters from the input
    leadingEdgeHeight = params(1);  % Leading Edge Height
    trailingEdgeHeight = params(2); % Trailing Edge Height
    chord = params(3);              % Chord
    topSweepHeight = params(4);     % Top Sweep Height
    lambda = params(5);             % Taper Ratio   
    wingSpan = params(6);           % Wing Station Size
    numBoxes = params(7);           % Number of Wingboxes
            
    % Coordinate System: z up/down, y left/right, x outboard
    x = (0:wingSpan/(numBoxes):wingSpan) .* ones(5, 1);
    y = [0, chord, chord, 0, 0];
    z = [leadingEdgeHeight, leadingEdgeHeight-topSweepHeight, ...
        leadingEdgeHeight-topSweepHeight-trailingEdgeHeight, ...
        0, leadingEdgeHeight]; % Y coordinates (height values)

    % Taper
    taper = x(1,:)/wingSpan*lambda + (wingSpan - x(1,:))./wingSpan.*1;

    % Plot the wingbox
    cla(ax); % Clear the previous plot
    for i=1:numel(x(1,:))
        plot3(ax, x(:, i), taper(i).*y, taper(i).*z, 'LineWidth', 2, 'Color', 'b');
        hold(ax, 'on')
    end
    for i=1:numel(y)-1
        plot3(ax, [x(i) x(end)], [y(i) taper(end).*y(i)], ...
            [z(i) taper(end).*z(i)], 'LineWidth', 2, 'Color', 'b');
    end
    set(ax, 'YDir', 'reverse')
    hold(ax, 'off')
    xlabel(ax, 'x')
    ylabel(ax, 'y')
    zlabel(ax, 'z')

    % Add margin to the y-axis
    if ~isnan(params)
        xMargin = 0.05;
        yMargin = 0.1;  % 10% margin
        zMargin = 0.1;

        yMin = 0 - yMargin * chord;
        yMax = chord + yMargin * chord;
    
        zMin = 0 - zMargin * leadingEdgeHeight;
        zMax = leadingEdgeHeight + zMargin * leadingEdgeHeight;
    
        xMin = 0 - xMargin * wingSpan;
        xMax = wingSpan + xMargin * wingSpan;

        % Margins
        xlim(ax, [xMin, xMax])
        ylim(ax, [yMin, yMax]);
        zlim(ax, [zMin, zMax]); 
    end
end

function plotWingbox(ax, params, type)
    % Extract the parameters from the input
    leadingEdgeHeight = params(1);  % Leading Edge Height
    trailingEdgeHeight = params(2); % Trailing Edge Height
    chord = params(3);              % Chord
    topSweepHeight = params(4);     % Top Sweep Height
    lambda = params(5);             % Taper Ratio   
    wingSpan = params(6);           % Wing Station Size
    numBoxes = params(7);           % Number of Wingboxes
    switch type
        case 'chord'
            y = [0, chord, chord, 0, 0];
            z = [leadingEdgeHeight, leadingEdgeHeight-topSweepHeight, leadingEdgeHeight-topSweepHeight-trailingEdgeHeight, 0, leadingEdgeHeight]; % Y coordinates (height values)
            
            cla(ax);
            plot(ax, y, z, 'LineWidth', 2, 'Color', 'b')
            axis(ax, 'off')
            
            if ~isnan(params)
                yMargin = 0.1;  % 10% margin
                zMargin = 0.1;
                
                yMin = 0 - yMargin * chord;
                yMax = chord + yMargin * chord;
            
                zMin = 0 - zMargin * leadingEdgeHeight;
                zMax = leadingEdgeHeight + zMargin * leadingEdgeHeight;
        
                xlim(ax, [yMin, yMax]);
                ylim(ax, [zMin, zMax]); 
            end
        case 'span'
            % For Root
            y = [0, wingSpan, wingSpan, 0, 0];
            z = [leadingEdgeHeight,leadingEdgeHeight/2 + (leadingEdgeHeight)*lambda/2, ...
                leadingEdgeHeight/2 - (leadingEdgeHeight)*lambda/2, ...
                0, leadingEdgeHeight]; % Y coordinates (height values)
            
            cla(ax);
            plot(ax, y, z, 'LineWidth', 2, 'Color', 'b')
            axis(ax, 'off')
            
            if ~isnan(params)
                yMargin = 0.1;  % 10% margin
                zMargin = 0.1;
                
                yMin = 0 - yMargin * wingSpan;
                yMax = wingSpan + yMargin * wingSpan;
            
                zMin = 0 - zMargin * leadingEdgeHeight;
                zMax = leadingEdgeHeight + zMargin * leadingEdgeHeight;
        
                xlim(ax, [yMin, yMax]);
                ylim(ax, [zMin, zMax]); 
            end
        otherwise
            error('Unknown type: %s', type);
    end
end






























