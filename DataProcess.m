clc;clear;close all;
% select_experiment=2;
experiment_list={'DJL_data_','DJT_data_','DMPC_data_','CCDR_data_'};
% for ind_experiment=3
tic
% for ind_experiment=1:length(experiment_list)
for ind_experiment=3
    switch ind_experiment
        case 1
            condition_list={'11111','21111','31111'};
        case 2
            condition_list={'11111','21111','31111'};
        case 3
            % condition_list={'11111','21111','31111','12111','13111','14111',...
            %     '11211','11311','11411','11121','11131','11112','11113'};
            condition_list={'2','4','7','14','18'};
        case 4
            condition_list={'11111','21111','31111'};
    end
    for ind_condition=1:length(condition_list)
%         clear except experiment_list condition_list ind_experiment ind_condition;
        clear file_name file_path fid data data_dict_upper data_dict_lower1 data_dict_lower2 data_dict_lower3 data_final;
        pyenv;
        file_name=[experiment_list{ind_experiment},condition_list{ind_condition}];
        file_path = ['D:\SUMO\work\',file_name,'.pkl'];
        fid=py.open(file_path,'rb');
        data=py.pickle.load(fid);
        % 将数据转换为 MATLAB 可用的格式
        data_dict_upper = struct(data);
        data_dict_lower1= struct(data_dict_upper.vehicle_indicator);
        data_dict_lower2= struct(data_dict_upper.frame_indicator);
        data_dict_lower3 = struct(data_dict_upper.dataframes);
        % switch ind_condition
        %     case 2
        %         vehicle_num=99;
        %     case 3
        %         vehicle_num=199;
        %     otherwise
        %         vehicle_num=299;
        % end
        vehicle_num=299;
        for i=0:vehicle_num
            element_name=['vehicle_',num2str(i)];
            data_final.vehicle_indicator.(element_name)=struct(data_dict_lower1.(element_name));
            vehicle_frame_i=struct(data_dict_lower3.(element_name));
            time_series=double(vehicle_frame_i.time);
            x_series=double(vehicle_frame_i.x);
            y_series=double(vehicle_frame_i.y);
            speed_series=double(vehicle_frame_i.speed);
            %% 修补数据错误
            distance_fixed1=sum(diff(x_series).^2+diff(y_series).^2);
            distance_fixed2=sum(0.05.*speed_series(1:end-1)+0.05.*speed_series(2:end));
            if abs(distance_fixed1-distance_fixed2)/min(distance_fixed1,distance_fixed2)<1
                distance_fixed=distance_fixed1;
            else
                distance_fixed=distance_fixed2;
            end
            data_final.vehicle_indicator.(element_name).distance=distance_fixed;
            data_final.vehicle_indicator.(element_name).averaspeed=distance_fixed/(data_final.vehicle_indicator.(element_name).disappear-data_final.vehicle_indicator.(element_name).appear);
            data_final.vehicle_frame.(element_name)=[time_series;x_series;y_series;speed_series];
        end
        element_name_list=fieldnames(data_dict_lower2);
        for i=1:length(element_name_list)
            element_name=element_name_list{i};
            data_final.instant_indicator.(element_name)=double(data_dict_lower2.(element_name));
        end
        save(file_name,'data_final');
    end
end
toc

