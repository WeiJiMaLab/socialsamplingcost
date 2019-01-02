classdef SampleGrid < handle
  properties
    sampleData
    lineWidth
    lineColour
    neutralColour
    goodColour
    badColour
    highlightColour
    highlightIndex
  end
  
  methods
    function this = SampleGrid(size, lineWidth, lineColour, neutralColour, goodColour, badColour, highlightColour)
      this.sampleData = zeros(size);
      this.lineWidth = lineWidth;
      this.lineColour = lineColour;
      this.neutralColour = neutralColour;
      this.goodColour = goodColour;
      this.badColour = badColour;
      this.highlightColour = highlightColour;
      this.highlightIndex = [0, 0];
    end
    
    function valid = isSelectionValid(this)
      valid = all([0, 0] < this.highlightIndex) && all(this.highlightIndex <= size(this.sampleData));
    end
    
    function draw(this, sc, left, top, right, bottom)
      width = right - left;
      height = bottom - top;
      [rows, cols] = size(this.sampleData);
      
      cellWidth  = (width  - (cols + 1) * this.lineWidth) / cols;
      cellHeight = (height - (rows + 1) * this.lineWidth) / rows;
      rectL = repmat([0:cols-1] * (this.lineWidth + cellWidth) + left, 1, rows);
      rectR = rectL + 2 * this.lineWidth + cellWidth;
      rectT = reshape(ones(cols, 1) * ([0:rows-1] * (this.lineWidth + cellHeight) + top), 1, rows * cols);
      rectB = rectT + 2 * this.lineWidth + cellHeight;
      
      samples = reshape(this.sampleData', 1, rows * cols);
      fillColours = this.neutralColour' * (samples == 0) + ...
                    this.goodColour' * (samples > 0) + ...
                    this.badColour' * (samples < 0);
      lineColours = this.lineColour;
      if (this.isSelectionValid())
        index = (this.highlightIndex(1) - 1) * cols + this.highlightIndex(2);
        rectL = [rectL rectL(index)];
        rectR = [rectR rectR(index)];
        rectT = [rectT rectT(index)];
        rectB = [rectB rectB(index)];
        fillColours = [fillColours fillColours(:, index)];
        lineColours = [this.lineColour' * ones(1, rows * cols), this.highlightColour'];
      end
      
      sc.rect(rectL, rectT, rectR, rectB, fillColours, this.lineWidth, lineColours);
    end
    
    function ok = moveSelection(this, direction)
      this.highlightIndex = this.highlightIndex + direction;
      ok = this.isSelectionValid();
      if (not(ok))
        this.highlightIndex = min(max([1 1], this.highlightIndex), size(this.sampleData));
      end
    end
    
    function sample = getSelected(this)
      if (this.isSelectionValid())
        sample = this.sampleData(this.highlightIndex(1), this.highlightIndex(2));
      else
        sample = NaN;
      end
    end
    
    function setSelected(this, value)
      if (this.isSelectionValid())
        this.sampleData(this.highlightIndex(1), this.highlightIndex(2)) = value;
      end
    end
  end
end
