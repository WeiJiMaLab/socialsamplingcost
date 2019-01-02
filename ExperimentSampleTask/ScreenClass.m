 classdef ScreenClass < handle
  properties (SetAccess = private)
    white
    grey
    black
    centerPx
    sizePx
    screenNumber
    window
    windowRect
    radiusPx
    topLeftPx

    VBLTimestamp
    StimulusOnsetTime
    FlipTimestamp

    delay
  end
  
  methods
    function this = ScreenClass(dimensions)
      % Setup PTB with some default values
      PsychDefaultSetup(2);

      % Seed the random number generator. Here we use the an older way to be
      % compatible with older systems. Newer syntax would be rng('shuffle'). Look
      % at the help function of rand "help rand" for more information
      rand('seed', sum(100 * clock));

      % Set the screen number to the external secondary monitor if there is one
      % connected
      this.screenNumber = max(Screen('Screens'));
      
      this.white = WhiteIndex(this.screenNumber);
      this.grey = white / 2;
      this.black = BlackIndex(this.screenNumber);
      % Open the screen
      [this.window, this.windowRect] = PsychImaging('OpenWindow', this.screenNumber, this.black, dimensions, 32, 2);

      % Flip to clear
      show(this);

      % Query the frame duration
      ifi = Screen('GetFlipInterval', this.window);

      % Set the text sizePx
      Screen('TextSize', this.window, 60);

      % Query the maximum priority level
      topPriorityLevel = MaxPriority(this.window);

      % Get the centre coordinate of the window
      [xc, yc] = RectCenter(this.windowRect);
      this.centerPx = [xc, yc];

      % Set the blend funciton for the screen
      Screen('BlendFunction', this.window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
      [xs, ys] = Screen('WindowSize', this.window);
      this.sizePx = [xs, ys];
      this.radiusPx = min(this.sizePx) * 0.5;
      this.topLeftPx = this.centerPx - this.radiusPx;
    end

    function show(this)
      [this.VBLTimestamp, this.StimulusOnsetTime, this.FlipTimestamp] = Screen('Flip', this.window, this.VBLTimestamp + this.delay);
      this.delay = 0;
  	end

	  function wait(this, delay)
      display('timing doesnt work in Matlab?');
      this.delay = this.delay + delay;
    end
    
    function rect = makeRect(this, left, top, right, bottom)
      rect = [this.centerPx(1) + (left  - 0.5) * this.sizePx(2),...
              top * this.sizePx(2),...
              this.centerPx(1) + (right - 0.5) * this.sizePx(2),...
              bottom * this.sizePx(2)];
    end
    
    function rect(this, left, top, right, bottom, color, edgeWidth, edgeColor)
      coords = ...
      [this.topLeftPx(1) + 2 * this.radiusPx * left;...
       this.topLeftPx(2) + 2 * this.radiusPx * top;...
       this.topLeftPx(1) + 2 * this.radiusPx * right;...
       this.topLeftPx(2) + 2 * this.radiusPx * bottom];
      if nargin < 7
        % filled rect
        Screen('FillRect', this.window, color, coords);
      elseif nargin < 8
        % hollow rect
        Screen('FrameRect', this.window, color, coords, edgeWidth * 2 * this.radiusPx);
      else
        % filled rect with edge
        edgePx = this.radiusPx * 2 * edgeWidth;
        innerCoords = coords + repmat([edgePx; edgePx; -edgePx; -edgePx], 1, size(coords, 2));
        Screen('FillRect', this.window, edgeColor, coords);
        Screen('FillRect', this.window, color, innerCoords);
      end
    end
      %textsize adjust the number to increase or decrease
    function textSize(this, size)
      Screen('TextSize', this.window, round(0.6 * size * this.radiusPx));
    end
    
    function text(this, text, colour, left, top, right, bottom)
      winRect = this.makeRect(left, top, right, bottom);
      DrawFormattedText(this.window, text, 'center', 'center', colour, 100, false, false, 1, 0, winRect);
    end
    
    function image(this, image, left, top, right, bottom)
      Screen('PutImage', this.window, image, this.makeRect(left, top, right, bottom));
    end
    
    function texture = makeTexture(this, image)
      texture = Screen('MakeTexture', this.window, image);
    end
    
    function texture(this, texture, left, top, right, bottom)
      winRect = this.makeRect(left, top, right, bottom);
      Screen('DrawTexture', this.window, texture, [], winRect);
    end
  end
end
