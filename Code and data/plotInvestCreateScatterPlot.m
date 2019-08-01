function legendHandles = plotInvestCreateScatterPlot(~, binProportionsPp, pInvestsFromModel, drawScatter, drawLine)
    legendHandles = zeros(4, 1);
    for money = 0:1
        for social = 0:1
            conditionNr = 1 + money + 2 * social;
            
            subjectProps = binProportionsPp(:,:,conditionNr);
            modelProps = pInvestsFromModel(:,:,conditionNr);
            colors = [0,191,255; 0,0,255;50,205,50; 0,100,0] / 255;
            size = 36;
            if drawScatter
                legendHandles(conditionNr, 1) = scatter(modelProps(:), subjectProps(:), size, colors(conditionNr, :));
            end
            if drawLine
                 % dit doet niets tenzij de functie aangeroepen wordt met
                 % 'true' als laatste argument
                legendHandles(conditionNr, 1) = plot(mean(modelProps), mean(subjectProps), '-', 'Color', colors(conditionNr, :), 'LineWidth', 2.5);
            end
        end
    end
end
