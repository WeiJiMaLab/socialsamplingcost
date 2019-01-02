function code = getKey(options, timeout)
  if nargin < 2
    timeout = 0;
  end
  keyLifted = false;
  timeId = tic();
  while(true)
    [keyIsDown, secs, keyCode] = KbCheck;
    keyPressed = false;
    for code = options
      if keyCode(code)
        keyPressed = true;
        if keyLifted || timeout > 0 && toc(timeId) > timeout
          return;
        end
      end
    end
    if ~keyPressed
      keyLifted = true;
    end
  end
end