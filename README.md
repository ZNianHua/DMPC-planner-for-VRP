# DMPC-planner-for-VRP
## Introduction
Here are the codes of a DMPC-based online planner for time-optimal vehicle routing problems (VRPs). 
Codes are constructed by Python programming language via jupyternotebook. 
Relevant simulations are carried out via SUMO platform, and the results are available at  
[Time-based Dijstra](https://youtu.be/6bpRLRHPPLw)  
[Length-based Dijstra](https://youtu.be/5hNTDw6ZxPY)  
[DMPC](https://youtu.be/UGi4Ibm2LHw)
## Contribution
Main contribution is the improved route planning, which includes multi-vehicle cooperation, local communication topology and dynamic traffic issues. 
The results shows the proposed method provide a optimal route via online planning, which makes the ego vehicle find a faster way towards multiple targets. 
Furthermore, the proposed method is able to schedule the multi-vehicle systems without locked cycle such as  
![Locked cycle in time-based Dijstra](https://github.com/ZNianHua/DMPC-planner-for-VRP/blob/main/DJT%20(online-video-cutter.com)%20-%20frame%20at%203m18s.jpg)
![Locked cycle in length-based Dijstra](https://github.com/ZNianHua/DMPC-planner-for-VRP/blob/main/DJL%20(online-video-cutter.com)%20(1)%20-%20frame%20at%204m0s.jpg)
