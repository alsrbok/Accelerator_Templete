# Accelerator_Templete
It can be used to build a spatial accelerator or an acccelerator for specific-mapping.

1) PE_new.v

Each PE has register file for activation, weight and partial sum.

PE_array_controller should send correct address and enable/selection signal to PE_array in order to progress the MAC operation.

![image](https://user-images.githubusercontent.com/43400865/188390841-c61203cf-2263-4ab4-931b-e9e9774f76f5.png)

2) psum_su_irrel_new.v

Since global buffers use high bandwidth(512 bits/cycle), partial sum from PE array should be accumulated using shorter clock than top_module.

However, you should consider the relation between the latency of overall temporal mapping on register files and the latency of psum_accumulator.

In this case, psum_su_irrel_new.v try to finish the calculation of the partial sum at one cycle. (But it requires high HW costs.)

![image](https://user-images.githubusercontent.com/43400865/188393306-2f2c191f-b213-42c8-b930-b87d3d0c2150.png)

3)Top_module.v

Detailed structure can be varied with the targeting accelerator.

Following structure is for the spatial accelerator.

![image](https://user-images.githubusercontent.com/43400865/188393720-401bcc15-d528-4ada-a17b-8b7d97ab3992.png)
