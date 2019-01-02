function sampleTrial(screen, fileID, grid, state, moneyTexture)
  escapeKey = KbName('ESCAPE');
  leftKey = KbName('LeftArrow');
  rightKey = KbName('RightArrow');
  upKey = KbName('UpArrow');
  downKey = KbName('DownArrow');
  enterKey = KbName('Return');
  spaceKey = KbName('Space');
  allKeys = [escapeKey, leftKey, rightKey, upKey, downKey, enterKey, spaceKey];
  
  faceImg = imread(state.faceFilename, 'jpg');
  faceTexture = screen.makeTexture(faceImg);
  
  grid.highlightIndex = round(size(grid.sampleData) / 2);
  key = 0;
  state.choiceHighlight = 0;
  state.nGood = 0;
  state.nBad = 0;
  state.nClosed = numel(grid.sampleData);
  state.trialStart = toc;
  decided = false;
  spelerNaam = ['Speler ', num2str(state.trialNr)];
  while (not(decided))
    % Top part of the screen
    screen.textSize(0.12);
    screen.texture(faceTexture, -0.1, 0.05, 0.15, 0.42);
    if (~state.costsSocial)
      screen.rect(-0.07, 0.18, 0.12, 0.26, screen.black);
    end
    if (state.costsMoney)
      screen.texture(moneyTexture, 0.3, 0.05, 0.5, 0.22);
      screen.text(num2str(state.nClosed), screen.white, 0.5, 0.05, 0.6, 0.22);
    else
      screen.text('Gratis', screen.white, 0.3, 0.05, 0.7, 0.22);
    end
    screen.rect(0.75, 0.05, 0.82, 0.12, grid.goodColour,    grid.lineWidth, grid.lineColour);
    screen.rect(0.87, 0.05, 0.94, 0.12, grid.badColour,     grid.lineWidth, grid.lineColour);
    screen.rect(0.99, 0.05, 1.06, 0.12, grid.neutralColour, grid.lineWidth, grid.lineColour);
    screen.text(num2str(state.nGood),   screen.white, 0.75, 0.15, 0.82, 0.22);
    screen.text(num2str(state.nBad),    screen.white, 0.87, 0.15, 0.94, 0.22);
    screen.text(num2str(state.nClosed), screen.white, 0.99, 0.15, 1.06, 0.22);
    
    % Grid and buttons
    grid.draw(screen, 0.25, 0.25, 0.75, 0.75);
    
    screen.textSize(0.2);
    if (state.choiceHighlight == 1)
      screen.rect(0.0, 0.75, 0.5, 1, screen.black, grid.lineWidth, grid.highlightColour);
    end
    if (state.choiceHighlight == -1)
      screen.rect(0.5, 0.75, 1.0, 1, screen.black, grid.lineWidth, grid.highlightColour);
    end
    screen.text('Investeer\nE5',  screen.white, 0.0, 0.75, 0.5, 1);
    screen.text('Investeer\nniet', screen.white, 0.5, 0.75, 1.0, 1);
    
    screen.show();
    key = getKey(allKeys);
    eventTime = toc;
    if (key == leftKey)
      if (state.choiceHighlight == 0)
        grid.moveSelection([0, -1]);
      else
        state.choiceHighlight = -state.choiceHighlight;
      end
    elseif (key == rightKey)
      if (state.choiceHighlight == 0)
        grid.moveSelection([0, 1]);
      else
        state.choiceHighlight = -state.choiceHighlight;
      end
    elseif (key == upKey)
      if (state.choiceHighlight == 0)
        grid.moveSelection([-1, 0]);
      else
        state.choiceHighlight = 0;
        grid.highlightIndex(1) = size(grid.sampleData, 1);
      end
    elseif (key == downKey)
      if (state.choiceHighlight == 0 && grid.moveSelection([1, 0]) == false)
        if (grid.highlightIndex(2) <= size(grid.sampleData, 2) / 2)
          state.choiceHighlight = 1;
        else
          state.choiceHighlight = -1;
        end
        grid.highlightIndex(1) = 0;
      end
    elseif (key == enterKey || key == spaceKey)
      if (state.choiceHighlight == 0)
        if (grid.getSelected() == 0)
          state.sampleOutcome = 1; % reciprocate
          if (rand > state.recipChance)
            state.sampleOutcome = -1; % reject
            state.nBad = state.nBad + 1;
          else
            state.nGood = state.nGood + 1;
          end
          state.nClosed = state.nClosed - 1;
          grid.setSelected(state.sampleOutcome);
          state.cursorX = num2str(grid.highlightIndex(2)); % indices go row first, then column
          state.cursorY = num2str(grid.highlightIndex(1));
          sampleLogEvent(fileID, eventTime, state);
        end
      else
        decided = true;
      end
    elseif (key == escapeKey)
      sca;
      error('Escaped');
    end
  end
  %feedback screen
  screen.textSize(0.3);
  if (state.choiceHighlight == 1)
    screen.text(['Investeer 5 Euro\nin ', spelerNaam], grid.goodColour, 0, 0, 1, 1);
  else
    screen.text(['Investeer niet\nin ', spelerNaam], grid.badColour, 0, 0, 1, 1);
  end
  screen.show();
  screen.wait(1);
  state.sampleOutcome = 0;
  state.cursorX = '';
  state.cursorY = '';
  sampleLogEvent(fileID, eventTime, state);
end