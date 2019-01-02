function runSampleTask(ppn)
  if nargin < 1
    error('Please supply a subject number')
  end
  % force reloading of classes
  %clear all;

  % define trial properties
  grid = [5, 5];
  costCombinations = [false false; true false; false true; true true];
  recipChances = [0.2, 0.4, 0.6, 0.8, 1];
  herhalingen = 10;

  % generate all combinations
  trials = [];
  for (chance = recipChances)
    trials = [trials; costCombinations, ones(4, 1) * chance];
  end

  % Repeat and shuffle
  trials = repmat(trials, herhalingen, 1);
  trials = trials(randperm(size(trials, 1)), :);

  % Put a face to each trial. Read all filenames, divide them in two halves, and
  % alternate random permutations. This guarantees there will be no repetitions
  % and each face will not be seen for at least half the nunber of the total amount.
  facePath = fullfile('.', 'Faces');
  facefiles = dir(fullfile(facePath, '*.jpg'));
  midIndex = floor(numel(facefiles) / 2);
  half1 = facefiles(1:midIndex);
  half2 = facefiles(midIndex + 1 : end);
  trialFace = half1(randperm(numel(half1)));
  chIndex = 1;
  while (numel(trialFace) < numel(trials))
    if (chIndex == 1)
      currentHalf = half2;
      chIndex = 2;
    else
      currentHalf = half1;
      chIndex = 1;
    end
    trialFace = [trialFace; currentHalf(randperm(numel(currentHalf)))];
  end
  trialFace = trialFace(1:numel(trials));

  errors = [];
  fileID = NaN;
  try
    % define graphics properties, determines window size
    % voor fullscreen use: screen = ScreenClass ([]);
    screen = ScreenClass([0 0 1280 960]);
    lijndikte = 0.01;
    lijnkleur = [1,1,1];
    vulkleur = [0.7,0.7,0.7];
    reciprocatekleur = [0, 1, 0.3];
    rejectkleur =  [1, 0.3, 0.3];
    keuzekleur = [0.5, 0.5, 0.7];

    % Run the task
    moneyTexture = screen.makeTexture(imread('Muntjes.png'));
    %filename = strrep([datestr(now), '.csv'], ':', '.');
    filename = ['sampletask-', num2str(ppn), '.csv'];
    fileID = fopen(filename, 'w');
    if (fileID == -1)
      sca;
      error(['Kon bestand ', filename, ' niet schrijven!']);
    end
    fprintf(fileID, 'trialNr, trialStart, eventTime, costsMoney, costsSocial, faceFile, recipChance, choice, green, red, closed, infoX, infoY, infoOutcome\n');
    tic;
    for trialNr = 1:size(trials,1)
      sampleGrid = SampleGrid(grid, lijndikte, lijnkleur, vulkleur, reciprocatekleur, rejectkleur, keuzekleur);
      state = struct(...
        'trialNr', trialNr,...
        'costsMoney', trials(trialNr, 1),...
        'costsSocial', trials(trialNr, 2),...
        'recipChance', trials(trialNr, 3),...
        'faceFilename', fullfile(facePath, trialFace(trialNr).name)...
      );
      sampleTrial(screen, fileID, sampleGrid, state, moneyTexture);
    end

    % Final screen
    screen.textSize(0.3);
    screen.text('Einde', screen.white, 0, 0, 1, 1);
    screen.show();
    screen.wait(2);
    screen.show();
  catch errors
  end

  % Error or not, we always close our resources
  sca;
  if ~isnan(fileID)
    fclose(fileID);
  end

  % If there was an error, rethrow it so we can debug
  if ~isempty(errors)
    rethrow(errors);
  end
end