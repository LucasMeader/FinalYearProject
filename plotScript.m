figure('Renderer', 'painters', 'Position', [400 100 1700 800]);
subplot(1,2,1), histogram(distanceArray(1:618)); hold on; title('NCC Distance: Center to Center'); xlabel('Distance in Pixels'); ylabel('Frequency');
%subplot(1,2,2), histogram(thetaArrayDegs(1:618)); hold on; title('Angle: Horizontal from Coordinate Center to Crop Center'); xlabel('Angle in Degrees'); ylabel('Frequency');
subplot(1,2,2), rose(thetaArrayDegs(1:618)); hold on; h = title('Angle: Horizontal from Coordinate Center to Crop Center'); view(90, -90); 
P = get(h,'Position');
set(h,'Position',[P(1)+65 P(2)-60 P(3)]);