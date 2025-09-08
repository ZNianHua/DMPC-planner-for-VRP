clc;clear;close all;
% target_folder='data_21111';
% loading_result={'DMPC_data_11111.mat','DJT_data_11111.mat','DJL_data_11111.mat','CCDR_data_11111.mat'};
% loading_result={'DMPC_data_21111.mat','DJT_data_21111.mat','DJL_data_21111.mat','CCDR_data_21111.mat'};
% loading_result={'DMPC_data_31111.mat','DJT_data_31111.mat','DJL_data_31111.mat','CCDR_data_31111.mat'};
% legend_i1={'DMPC','DJT','DJL','DCRT'};
% loading_result={'DMPC_data_12111.mat','DMPC_data_11111.mat','DMPC_data_13111.mat','DMPC_data_14111.mat'};
% legend_i1={'v^r=10','v^r=15','v^r=20','v^r=25'};
% loading_result={'DMPC_data_11211.mat','DMPC_data_11311.mat','DMPC_data_11111.mat','DMPC_data_11411.mat'};
% legend_i1={'\theta^r=0.3','\theta^r=0.5','\theta^r=0.7','\theta^r=1'};
% loading_result={'DMPC_data_11121.mat','DMPC_data_11111.mat','DMPC_data_11131.mat'};
% legend_i1={'k_Q=1','k_Q=2','k_Q=3'};
% loading_result={'DMPC_data_11112.mat','DMPC_data_11111.mat','DMPC_data_11113.mat'};
% legend_i1={'k_C=0.1','k_C=0.5','k_C=1'};
loading_result={'DMPC_data_2.mat','DMPC_data_4.mat','DMPC_data_7.mat','DMPC_data_14.mat','DMPC_data_18.mat'};
cata_thres=5;
num_result=length(loading_result);
duration_steps.time=1000;
duration_steps.distance=1000;
duration_steps.speed=0.5;
distance_duration_step=1000;
time_duration_step=1000;
speed_duration_step=0.5;

indicator_cell_vehicle=cell(1,num_result);
indicator_cell_time=cell(1,num_result);
dateframe_cell=cell(1,num_result);

for result_i=1:num_result
    load(loading_result{result_i})
    [vehicle_indicator_matrix,frame_indicator_matrix] = indicator_calculation(data_final);
    indicator_cell_vehicle{result_i}=vehicle_indicator_matrix;
    indicator_cell_time{result_i}=frame_indicator_matrix;
    dateframe_cell{result_i}=data_final.vehicle_frame;
    min_value_i=min(vehicle_indicator_matrix,[],2);
    max_value_i=max(vehicle_indicator_matrix,[],2);
    min_value_matrix(:,result_i)=min_value_i;
    max_value_matrix(:,result_i)=max_value_i;
end
%% 自适应调整区间
min_time=min(min_value_matrix(5,:));
max_time=max(max_value_matrix(5,:));
if (max_time-min_time)/time_duration_step>cata_thres
    time_duration_step=ceil((max_time-min_time)/cata_thres/time_duration_step)*duration_steps.time;
end
start_point=floor(min_time/time_duration_step);
end_point=ceil(max_time/time_duration_step);
axis_cell{1}=time_duration_step*(start_point:end_point);

min_distance=min(min_value_matrix(3,:));
max_distance=max(max_value_matrix(3,:));
if (max_distance-min_distance)/distance_duration_step>cata_thres
    distance_duration_step=ceil((max_distance-min_distance)/cata_thres/distance_duration_step)*duration_steps.distance;
end
start_point=floor(min_distance/distance_duration_step);
end_point=ceil(max_distance/distance_duration_step);
axis_cell{2}=distance_duration_step*(start_point:end_point);

min_speed=min(min_value_matrix(4,:));
max_speed=max(max_value_matrix(4,:));
if (max_speed-min_speed)/speed_duration_step>cata_thres
    speed_duration_step=ceil((max_speed-min_speed)/cata_thres/speed_duration_step)*duration_steps.speed;
end
start_point=floor(min_speed/speed_duration_step);
end_point=ceil(max_speed/speed_duration_step);
axis_cell{3}=speed_duration_step*(start_point:end_point);
counters_cell={zeros(num_result,length(axis_cell{1})-1),...
    zeros(num_result,length(axis_cell{2})-1),...
    zeros(num_result,length(axis_cell{3})-1)};
for result_i=1:num_result
    for axis_i=1:3
        axis_now=axis_cell{axis_i};
        switch axis_i
            case 1
                data_index_in_matrix=5;
            case 2
                data_index_in_matrix=3;
            case 3
                data_index_in_matrix=4;
        end
        counters_single=histcounts(indicator_cell_vehicle{result_i}(data_index_in_matrix,:),axis_now);
        counters_cell{axis_i}(result_i,:)=counters_single;
    end
end
%% ANOVA
[analysis_results_vehicle] = ANOVA_TLconfiguration(indicator_cell_vehicle);
%% 绘图
close all;clc;
fast_step_for_fill=10;
subfig_label={'(a)','(b)','(c)','(d)'};
line_style={'-','-.','--',':'};
line_witdh={1,1.5,1.7,2};
line_marker={'o','s','d','^'};
fill_color={[0.00,0.45,0.74],[0.85,0.33,0.10],[0.93,0.69,0.13],[0.49,0.18,0.56]};
fill_alpha={0.2,0.2,0.2,0.2};
plot_counters=1;
% 调度系统车数变化曲线
figure(plot_counters)
for plot_i=1:num_result
    plot(indicator_cell_time{plot_i}(1,:),indicator_cell_time{plot_i}(2,:), ...
        'LineStyle',line_style{plot_i},'LineWidth',line_witdh{plot_i})
    hold on
end
legend(legend_i1,'Location','northeast')
ylim([0,max(indicator_cell_time{plot_i}(2,:))+10])
xlim([-100,ceil(max_time/100)*100])
xlabel('time/(s)')
ylabel('scheduling number/(-)')
grid on
plot_counters=plot_counters+1;
print('-dpng', ['D:\znh\LatexWork\DMPCschedule\T-ITS-25-07-3451_response_250901\',target_folder,'onlinevehicles.png'], '-r600');
% 每时刻平均车速
figure(plot_counters)

y_upper=cell(1,num_result);
y_lower=cell(1,num_result);
for plot_i=1:num_result
    subplot(num_result,1,plot_i)
    chosen_indicator_time=indicator_cell_time{plot_i};
    [y_upper{plot_i},y_lower{plot_i}]=envelope(chosen_indicator_time(3,:),500,'peak');
    y_upper{plot_i}(find(y_upper{plot_i}<0))=0;
    x_plot=chosen_indicator_time(1,:);
    fill([x_plot(1),x_plot(end), fliplr(x_plot(1:fast_step_for_fill:end))], ...
        [0,0, fliplr(y_upper{plot_i}(1:fast_step_for_fill:end))],fill_color{plot_i}, ...
        'FaceAlpha',3*fill_alpha{plot_i},'EdgeColor','none')
    hold on
    plot(x_plot,chosen_indicator_time(3,:),'Color',fill_color{plot_i}, ...
        'LineStyle',line_style{plot_i},'LineWidth',line_witdh{plot_i}*0.5)
    legend('envelope area','velocity','Location','northwest')
    xlim([-100,ceil(max_time/100)*100])
    ylim([0,20])
    xlabel({'time/(s)',subfig_label{plot_i}})
    ylabel('average velocity/(m/s)')
%     ylabel('average velocities of dataframes/(m/s)')
%     title(legend_i1{plot_i})
    grid on
end
plot_counters=plot_counters+1;
% 每时刻平均速度包络线
figure(plot_counters)
for plot_i=1:num_result
    x_plot=indicator_cell_time{plot_i}(1,:);
    fill([x_plot(1),x_plot(end), fliplr(x_plot(1:fast_step_for_fill:end))], ...
        [0,0, fliplr(y_upper{plot_i}(1:fast_step_for_fill:end))],fill_color{plot_i}, ...
        'FaceAlpha',fill_alpha{plot_i},'EdgeColor',fill_color{plot_i})
    hold on
end
ylim([0,20])
xlim([-100,ceil(max_time/100)*100])
xlabel('time/(s)')
ylabel('average velocity/(m/s)')
grid on
legend(legend_i1,'Location','northwest')
plot_counters=plot_counters+1;
print('-dpng', ['D:\znh\LatexWork\DMPCschedule\T-ITS-25-07-3451_response_250901\',target_folder,'envolopes.png'], '-r600');
% 车辆起止时间分布
figure(plot_counters)
P=cell(1,num_result);
for plot_i=1:num_result
    subplot(2,2,plot_i)
    chosen_indicator_vehicle=indicator_cell_vehicle{plot_i};
    P{plot_i}=convhull(chosen_indicator_vehicle(1:2,:)');
    fill(chosen_indicator_vehicle(1,P{plot_i}),chosen_indicator_vehicle(2,P{plot_i}),fill_color{plot_i},'FaceAlpha',fill_alpha{plot_i},'EdgeColor','none')
    hold on
    scatter(chosen_indicator_vehicle(1,:),chosen_indicator_vehicle(2,:),line_marker{plot_i},'MarkerEdgeColor',fill_color{plot_i})
%     xlim([-100,ceil(max(max_value_matrix(1,:))/100)*100])
    ylim([0,ceil(max(max_value_matrix(2,:))/100)*100])
    xlabel({'beginning time/(s)',subfig_label{plot_i}})
    ylabel('arriving time/(s)')
%     title(legend_i1{plot_i})
    grid on
end
plot_counters=plot_counters+1;
print('-dpng', ['D:\znh\LatexWork\DMPCschedule\T-ITS-25-07-3451_response_250901\',target_folder,'beginarrivephase.png'], '-r600');
%% 车辆采样
% 随机采样的车辆速度曲线
figure(plot_counters)
windowSize = 1000; 
b = (1/windowSize)*ones(1,windowSize);
a = 1;
% num_sample_vehicle=3;
% s = RandStream('mlfg6331_64'); 
% sampled_vehicle_index=randsample(s,299,num_sample_vehicle)
% feasible: 8,178,266,98,144,113
% sampled_vehicle_index=[8,98,178]-1;
sampled_vehicle_index=[8,98];
% sampled_vehicle_index=[105,225,246]-1;
num_sample_vehicle=length(sampled_vehicle_index);
saved_vehicle_sequence=cell(num_sample_vehicle,num_result);
for plot_i=1:num_sample_vehicle
    index_i=sampled_vehicle_index(plot_i);
    subplot(num_sample_vehicle,1,plot_i);
    for plot_ii=1:num_result
        element_name=['vehicle_',num2str(index_i)];
        sequences_selected=dateframe_cell{plot_ii};
        sequence_i=sequences_selected.(element_name);
        saved_vehicle_sequence{plot_i,plot_ii}=sequence_i;
%         [y_upper_i,y_lower_i]=envelope(sequence_i(4,:),100,'peak');
        y_upper_i = filter(b,a,sequence_i(4,:));
        y_upper_i(find(y_upper_i<0))=0;
        x_plot=sequence_i(1,:);
%         fill([x_plot(1),x_plot(end), fliplr(x_plot(1:fast_step_for_fill:end))],[0,0, fliplr(y_upper_i(1:fast_step_for_fill:end))], ...
%             fill_color{plot_ii},'FaceAlpha',fill_alpha{plot_ii},'EdgeColor',fill_color{plot_ii})
%         hold on
%         plot(x_plot,sequence_i(4,:), 'Color',fill_color{plot_ii}, ...
%             'LineStyle',line_style{plot_ii},'LineWidth',line_witdh{plot_ii})
%         hold on
        plot(x_plot,y_upper_i, 'Color',fill_color{plot_ii}, ...
            'LineStyle',line_style{plot_ii},'LineWidth',line_witdh{plot_ii})
        hold on
    end
    legend(legend_i1)
%     legend(reshape([legend_i1;legend_i1],2*num_result,1),'Location','northwest')
    xlabel({'time/(s)',subfig_label{plot_i}})
    ylabel('vehicle velocity/(m/s)')
end
plot_counters=plot_counters+1;
% 随机采样的车辆轨迹曲线
figure(plot_counters)
for plot_i=1:num_sample_vehicle
    subplot(num_sample_vehicle,1,plot_i);
    for plot_ii=1:num_result
        sequence_current=saved_vehicle_sequence{plot_i,plot_ii};
        plot(sequence_current(2,:),sequence_current(3,:),'Color', ...
            fill_color{plot_ii},'LineStyle',line_style{plot_ii},'LineWidth',line_witdh{plot_ii})
        hold on
    end
    legend(legend_i1)
    xlabel({'global X/(m)',subfig_label{plot_i}})
    ylabel('global Y/(m)')
end
plot_counters=plot_counters+1;
%% 车辆总运行时间、总里程、平均速度的分布柱状图
for plot_counter_i=1:3
    % switch plot_counter_i
    %     case 1
    %         des_unit='/(s)';
    %     case 2
    %         des_unit='/(m)';
    %     case 3
    %         des_unit='/(m/s)';
    % end
    switch plot_counter_i
        case 1
            des_unit=' [s]';
        case 2
            des_unit=' [m]';
        case 3
            des_unit=' [m/s]';
    end
    figure(plot_counters)
    edge_i=axis_cell{plot_counter_i};
    [n_row,n_col]=size(counters_cell{plot_counter_i});
    if n_row==length(edge_i)-1 && n_col==length(edge_i)-1
        bar(edge_i(1:end-1),counters_cell{plot_counter_i}','EdgeColor','none')
    else
        bar(edge_i(1:end-1),counters_cell{plot_counter_i},'EdgeColor','none')
    end
    % ylabel('number/(-)');
    ylabel('number [-]');
    legend(legend_i1)
    if length(edge_i)>5
        skip_num=round((length(edge_i)-1)/5);
    else
        skip_num=1;
    end
    xticks_vector=edge_i(1:skip_num:end-1);
    xticks(xticks_vector)
    bar_label=cell(1,length(xticks_vector));
    for bar_x_label_i=1:length(xticks_vector)
        
        if bar_x_label_i==length(xticks_vector)
            bar_label{bar_x_label_i}=[num2str(xticks_vector(bar_x_label_i)),'~',num2str(edge_i(end)),des_unit]; 
        else
            bar_label{bar_x_label_i}=[num2str(xticks_vector(bar_x_label_i)),'~',num2str(xticks_vector(bar_x_label_i+1)),des_unit];   
        end
    end
    xticklabels(bar_label); % 设置x轴刻度标签
    xtickangle(45); % 旋转x轴刻度标签，便于显示
    grid on    
    plot_counters=plot_counters+1;
    print('-dpng', ['D:\znh\LatexWork\DMPCschedule\T-ITS-25-07-3451_response_250901\',target_folder,'statisticalbars',num2str(plot_counter_i),'.png'], '-r600');
end

%%
% 车辆运行属性的包络
vehplot_step=3;
windowSize = 10; 
b = (1/windowSize)*ones(1,windowSize);
a = 1;
for plot_i=1:3
    figure(plot_counters)
    switch plot_i
        case 1
            data_index_in_matrix=5;
            ylabel_text='routing duration/(s)';
        case 2
            data_index_in_matrix=3;
            ylabel_text='traveling length/(m)';
        case 3
            data_index_in_matrix=4;
            ylabel_text='average speed/(m/s)';
    end
    for plot_ii=1:num_result
        chosen_indicator_vehicle=indicator_cell_vehicle{plot_ii};
%         [y_upper_i,~]=envelope(chosen_indicator_vehicle(data_index_in_matrix,:),3,'peak');
        y_upper_i=filter(b,a,chosen_indicator_vehicle(data_index_in_matrix,:));
        y_upper_i(find(y_upper_i<0))=0;
        num_vehicles=length(indicator_cell_vehicle{plot_ii});
        bar(1:vehplot_step:num_vehicles,chosen_indicator_vehicle(data_index_in_matrix,1:vehplot_step:num_vehicles),'FaceColor', ...
            fill_color{plot_ii},'FaceAlpha',fill_alpha{plot_ii}*0.5,'EdgeColor','none')
        hold on
        plot(windowSize:num_vehicles,y_upper_i(windowSize:end), 'Color',fill_color{plot_ii}, ...
            'LineStyle',line_style{plot_ii},'LineWidth',line_witdh{plot_ii})
        hold on
%         fill([1,300, 300:-1:1],[0,0, fliplr(y_upper_i)],fill_color{plot_ii}, ...
%         'FaceAlpha',fill_alpha{plot_ii},'EdgeColor',fill_color{plot_ii})
%         hold on
%         plot(1:3:300,chosen_indicator_vehicle(data_index_in_matrix,1:3:end), ...
%             'Color',fill_color{plot_ii},'LineStyle',line_style{plot_ii},'LineWidth',line_witdh{plot_ii})
%         hold on
    end
    xlabel('vehicle index/(-)')
    ylabel(ylabel_text)
    grid on
%     legend(legend_i1,'Location','northwest')
    legend(reshape([legend_i1;legend_i1],2*num_result,1),'Location','northwest')
    plot_counters=plot_counters+1;
    print('-dpng', ['D:\znh\LatexWork\DMPCschedule\T-ITS-25-07-3451_response_250901\',target_folder,'vehicleattributes',num2str(plot_i),'.png'], '-r600');
end
%% 弃用
%% 起止时间分布凸集对比
figure(plot_counters)
for plot_i=1:num_result
    chosen_indicator_vehicle=indicator_cell_vehicle{plot_i};
    fill(chosen_indicator_vehicle(1,P{plot_i}),chosen_indicator_vehicle(2,P{plot_i}),fill_color{plot_i},'FaceAlpha',fill_alpha{plot_i},'EdgeColor',fill_color{plot_i})
    hold on
    
end
xlim([-100,ceil(max(max_value_matrix(1,:))/100)*100])
ylim([0,ceil(max(max_value_matrix(2,:))/100)*100])
xlabel('beginning time/(s)')
ylabel('arriving time/(s)')
legend(legend_i1)
grid on
plot_counters=plot_counters+1;
%% 包络线上下界及其区域对比
% figure(plot_counters)
% for plot_i=1:num_result
%     x_plot=indicator_cell_time{plot_i}(1,:);
%     subplot(3,1,1)
%     plot(x_plot,y_lower{plot_i},'Color',fill_color{plot_i},'LineStyle',line_style{plot_i},'LineWidth',line_witdh{plot_i})
%     hold on
%     subplot(3,1,2)
%     plot(x_plot,y_upper{plot_i},'Color',fill_color{plot_i},'LineStyle',line_style{plot_i},'LineWidth',line_witdh{plot_i})
%     hold on
%     subplot(3,1,3)
%     fill([x_plot, fliplr(x_plot)],[y_lower{plot_i}, fliplr(y_upper{plot_i})],fill_color{plot_i},'FaceAlpha',2*fill_alpha{plot_i},'EdgeColor',fill_color{plot_i})
%     hold on
% end
% for subfig_i=1:3
%     subplot(3,1,subfig_i)
%     ylim([-5,15])
%     xlim([-100,ceil(max_time/100)*100])
%     xlabel({'time/(s)',subfig_label{subfig_i}})
%     ylabel('average velocity/(m/s)')
%     grid on
%     legend(legend_i1,'Location','northwest')
% %     switch subfig_i
% %         case 1
% %             title('lower boundary/(m/s)')
% %         case 2
% %             title('upper boundary/(m/s)')
% %         case 3
% %             title('envelope area/(m/s)')
% %     end
% 
% end

