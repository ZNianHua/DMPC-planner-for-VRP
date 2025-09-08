function [vehicle_indicator_matrix,frame_indicator_matrix] = indicator_calculation(data_final)
vehicle_indicator_selected=data_final.vehicle_indicator;
filename_list=fieldnames(vehicle_indicator_selected);
vehicle_indicator_matrix=zeros(5,length(filename_list));
for i=1:length(filename_list)
    current_name=filename_list{i};
    vehicle_indicator_matrix(1,i)=vehicle_indicator_selected.(current_name).appear;
    vehicle_indicator_matrix(2,i)=vehicle_indicator_selected.(current_name).disappear;
    vehicle_indicator_matrix(3,i)=vehicle_indicator_selected.(current_name).distance;
    vehicle_indicator_matrix(4,i)=vehicle_indicator_selected.(current_name).averaspeed;
    vehicle_indicator_matrix(5,i)=vehicle_indicator_selected.(current_name).disappear-vehicle_indicator_selected.(current_name).appear;
end
frame_indicator_selected=data_final.instant_indicator;
filename_list=fieldnames(frame_indicator_selected);
frame_indicator_matrix=zeros(3,length(filename_list));
for i=1:length(filename_list)
    current_name=filename_list{i};
    frame_indicator_matrix(1,i)=0.1*i;
    frame_indicator_matrix(2,i)=frame_indicator_selected.(current_name)(1);
    frame_indicator_matrix(3,i)=frame_indicator_selected.(current_name)(2);
end

end