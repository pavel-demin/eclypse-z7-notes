# Create port_slicer
cell pavel-demin:user:port_slicer slice_0 {
  DIN_WIDTH 8 DIN_FROM 0 DIN_TO 0
}

# Create port_slicer
cell pavel-demin:user:port_slicer slice_1 {
  DIN_WIDTH 288 DIN_FROM 15 DIN_TO 0
}

for {set i 0} {$i <= 7} {incr i} {

  # Create port_slicer
  cell pavel-demin:user:port_slicer slice_[expr $i + 2] {
    DIN_WIDTH 288 DIN_FROM [expr $i + 16] DIN_TO [expr $i + 16]
  }

  # Create port_selector
  cell pavel-demin:user:port_selector selector_$i {
    DOUT_WIDTH 16
  } {
    cfg slice_[expr $i + 2]/dout
    din /adc_0/m_axis_tdata
  }

  # Create port_slicer
  cell pavel-demin:user:port_slicer slice_[expr $i + 10] {
    DIN_WIDTH 288 DIN_FROM [expr 32 * $i + 63] DIN_TO [expr 32 * $i + 32]
  }

  # Create axis_constant
  cell pavel-demin:user:axis_constant phase_$i {
    AXIS_TDATA_WIDTH 32
  } {
    cfg_data slice_[expr $i + 10]/dout
    aclk /pll_0/clk_out1
  }

  # Create dds_compiler
  cell xilinx.com:ip:dds_compiler dds_$i {
    DDS_CLOCK_RATE 122.88
    SPURIOUS_FREE_DYNAMIC_RANGE 138
    FREQUENCY_RESOLUTION 0.2
    PHASE_INCREMENT Streaming
    HAS_PHASE_OUT false
    PHASE_WIDTH 30
    OUTPUT_WIDTH 24
    DSP48_USE Minimal
    NEGATIVE_SINE true
  } {
    S_AXIS_PHASE phase_$i/M_AXIS
    aclk /pll_0/clk_out1
  }

}

# Create axis_lfsr
cell pavel-demin:user:axis_lfsr lfsr_0 {} {
  aclk /pll_0/clk_out1
  aresetn /rst_0/peripheral_aresetn
}

# Create xlconstant
cell xilinx.com:ip:xlconstant const_0

for {set i 0} {$i <= 15} {incr i} {

  # Create port_slicer
  cell pavel-demin:user:port_slicer dds_slice_$i {
    DIN_WIDTH 48 DIN_FROM [expr 24 * ($i % 2) + 23] DIN_TO [expr 24 * ($i % 2)]
  } {
    din dds_[expr $i / 2]/m_axis_data_tdata
  }

  # Create xbip_dsp48_macro
  cell xilinx.com:ip:xbip_dsp48_macro mult_$i {
    INSTRUCTION1 RNDSIMPLE(A*B+CARRYIN)
    A_WIDTH.VALUE_SRC USER
    B_WIDTH.VALUE_SRC USER
    OUTPUT_PROPERTIES User_Defined
    A_WIDTH 24
    B_WIDTH 14
    P_WIDTH 25
  } {
    A dds_slice_$i/dout
    B selector_[expr $i / 2]/dout
    CARRYIN lfsr_0/m_axis_tdata
    CLK /pll_0/clk_out1
  }

  # Create axis_variable
  cell pavel-demin:user:axis_variable rate_$i {
    AXIS_TDATA_WIDTH 16
  } {
    cfg_data slice_1/dout
    aclk /pll_0/clk_out1
    aresetn /rst_0/peripheral_aresetn
  }

  # Create cic_compiler
  cell xilinx.com:ip:cic_compiler cic_$i {
    INPUT_DATA_WIDTH.VALUE_SRC USER
    FILTER_TYPE Decimation
    NUMBER_OF_STAGES 6
    SAMPLE_RATE_CHANGES Programmable
    MINIMUM_RATE 160
    MAXIMUM_RATE 2560
    FIXED_OR_INITIAL_RATE 1280
    INPUT_SAMPLE_FREQUENCY 122.88
    CLOCK_FREQUENCY 122.88
    INPUT_DATA_WIDTH 24
    QUANTIZATION Truncation
    OUTPUT_DATA_WIDTH 32
    USE_XTREME_DSP_SLICE false
    HAS_ARESETN true
  } {
    s_axis_data_tdata mult_$i/P
    s_axis_data_tvalid const_0/dout
    S_AXIS_CONFIG rate_$i/M_AXIS
    aclk /pll_0/clk_out1
    aresetn /rst_0/peripheral_aresetn
  }

}

# Create axis_combiner
cell  xilinx.com:ip:axis_combiner comb_0 {
  TDATA_NUM_BYTES.VALUE_SRC USER
  TDATA_NUM_BYTES 4
  NUM_SI 16
} {
  S00_AXIS cic_0/M_AXIS_DATA
  S01_AXIS cic_1/M_AXIS_DATA
  S02_AXIS cic_2/M_AXIS_DATA
  S03_AXIS cic_3/M_AXIS_DATA
  S04_AXIS cic_4/M_AXIS_DATA
  S05_AXIS cic_5/M_AXIS_DATA
  S06_AXIS cic_6/M_AXIS_DATA
  S07_AXIS cic_7/M_AXIS_DATA
  S08_AXIS cic_8/M_AXIS_DATA
  S09_AXIS cic_9/M_AXIS_DATA
  S10_AXIS cic_10/M_AXIS_DATA
  S11_AXIS cic_11/M_AXIS_DATA
  S12_AXIS cic_12/M_AXIS_DATA
  S13_AXIS cic_13/M_AXIS_DATA
  S14_AXIS cic_14/M_AXIS_DATA
  S15_AXIS cic_15/M_AXIS_DATA
  aclk /pll_0/clk_out1
  aresetn /rst_0/peripheral_aresetn
}

# Create axis_dwidth_converter
cell xilinx.com:ip:axis_dwidth_converter conv_0 {
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 64
  M_TDATA_NUM_BYTES 4
} {
  S_AXIS comb_0/M_AXIS
  aclk /pll_0/clk_out1
  aresetn /rst_0/peripheral_aresetn
}

# Create fir_compiler
cell xilinx.com:ip:fir_compiler fir_0 {
  DATA_WIDTH.VALUE_SRC USER
  DATA_WIDTH 32
  COEFFICIENTVECTOR {-9.7183443203e-09, 2.1018216881e-08, 9.6024488521e-09, -2.4087477079e-08, -8.1423949947e-09, 2.7829908603e-08, 5.0459558021e-09, -3.2792961253e-08, -8.7493265126e-11, 3.9658707043e-08, -6.8593101817e-09, -4.9242190366e-08, 1.5780611408e-08, 6.2474530539e-08, -2.6490103688e-08, -8.0388121559e-08, 3.8587584901e-08, 1.0408565660e-07, -5.1424493976e-08, -1.3470358155e-07, 6.4069374884e-08, 1.7336089207e-07, -7.5285999914e-08, -2.2110585899e-07, 8.3513736086e-08, 2.7884886851e-07, -8.6868329262e-08, -3.4731055047e-07, 8.3113354043e-08, 4.2690052017e-07, -6.9728273535e-08, -5.1768189064e-07, 4.3912141525e-08, 6.1927450281e-07, -2.6449990600e-09, -7.3078881085e-07, -5.7258660379e-08, 8.5073459712e-07, 1.3903944093e-07, -9.7698241404e-07, -2.4590456526e-07, 1.1067087347e-06, 3.8090322322e-07, -1.2363732525e-06, -5.4680286615e-07, 1.3616983349e-06, 7.4593102033e-07, -1.4776973846e-06, -9.8003095819e-07, 1.5787101457e-06, 1.2500794491e-06, -1.6585436949e-06, -1.5562502454e-06, 1.7104220953e-06, 1.8975988987e-06, -1.7272773341e-06, -2.2720424370e-06, 1.7018573100e-06, 2.6762188358e-06, -1.6269525965e-06, -3.1054449656e-06, 1.4955690485e-06, 3.5536079574e-06, -1.3012333868e-06, -4.0131979608e-06, 1.0382380087e-06, 4.4753338337e-06, -7.0193371176e-07, -4.9298766655e-06, 2.8897639035e-07, 5.3655378184e-06, 2.0237226313e-07, -5.7700961445e-06, -7.7201393798e-07, 6.1305800188e-06, 1.4176102267e-06, -6.4338873737e-06, -2.1348157389e-06, 6.6666874915e-06, 2.9167305358e-06, -6.8161252774e-06, -3.7539939935e-06, 6.8701868556e-06, 4.6347267011e-06, -6.8182526351e-06, -5.5447232220e-06, 6.6514585653e-06, 6.4675064692e-06, -6.3632680210e-06, -7.3846392061e-06, 5.9499175293e-06, 8.2760543576e-06, -5.4109071995e-06, -9.1205837492e-06, 4.7493140703e-06, 9.8964531020e-06, -3.9721441677e-06, -1.0581975595e-05, 3.0903891146e-06, 1.1155862208e-05, -2.1198565611e-06, -1.1598974212e-05, 1.0800930859e-06, 1.1894192377e-05, 5.0764673657e-09, -1.2027655248e-05, -1.1080294379e-06, 1.1989500776e-05, 2.1976691450e-06, -1.1774887356e-05, -3.2402837230e-06, 1.1384548678e-05, 4.2001905382e-06, -1.0825554933e-05, -5.0407409059e-06, 1.0111810348e-05, 5.7253291919e-06, -9.2645864987e-06, -6.2187649526e-06, 8.3126383806e-06, 6.4885530044e-06, -7.2923194553e-06, -6.5066660743e-06, 6.2465071930e-06, 6.2495174910e-06, -5.2261624079e-06, -5.7016749208e-06, 4.2875700188e-06, 4.8558404072e-06, -3.4921305935e-06, -3.7145535560e-06, 2.9048726877e-06, 2.2911751746e-06, -2.5932018757e-06, -6.1127551357e-07, 2.6247343291e-06, -1.2868396408e-06, -3.0653879786e-06, 3.3515646366e-06, 3.9770466729e-06, -5.5180087231e-06, -5.4153975382e-06, 7.7079974544e-06, 7.4272860215e-06, -9.8308154538e-06, -1.0048404030e-05, 1.1783610692e-05, 1.3299174052e-05, -1.3455845078e-05, -1.7186393143e-05, 1.4726895083e-05, 2.1697150713e-05, -1.5471333700e-05, -2.6798566084e-05, 1.5561105341e-05, 3.2435989363e-05, -1.4869088240e-05, -3.8532416868e-05, 1.3272108299e-05, 4.4987430871e-05, -1.0655155484e-05, -5.1677456070e-05, 6.9152844262e-06, 5.8456294840e-05, -1.9659814242e-06, -6.5156848727e-05, -4.2590985594e-06, 7.1592951923e-05, 1.1802029691e-05, -7.7562514342e-05, -2.0678149910e-05, 8.2847991428e-05, 3.0867318870e-05, -8.7228024371e-05, -4.2319264614e-05, 9.0474987984e-05, 5.4946101683e-05, -9.2363424425e-05, -6.8622152833e-05, 9.2675515616e-05, 8.3182977615e-05, -9.1208028784e-05, -9.8426582324e-05, 8.7778099147e-05, 1.1411435016e-04, -8.2230121207e-05, -1.2997378627e-04, 7.4442015036e-05, 1.4570184837e-04, -6.4331942666e-05, -1.6097032297e-04, 5.1863672862e-05, 1.7543162504e-04, -3.7052151243e-05, -1.8872803133e-04, 1.9962162126e-05, 2.0048996784e-04, -7.2469728068e-07, -2.1035949362e-04, -2.0474377462e-05, 2.1799027829e-04, 4.3388540331e-05, -2.2305979018e-04, -6.7712424724e-05, 2.2527905946e-04, 9.3083766880e-05, -2.2440402737e-04, -1.1908891324e-04, 2.2024487201e-04, 1.4526870106e-04, -2.1267575306e-04, -1.7112681186e-04, 2.0164295580e-04, 1.9613879988e-04, -1.8717315606e-04, -2.1976389992e-04, 1.6937935987e-04, 2.4145699519e-04, -1.4846911541e-04, -2.6069232784e-04, 1.2472986538e-04, 2.7695526551e-04, -9.8554828406e-05, -2.8978124284e-04, 7.0423921070e-05, 2.9876248513e-04, -4.0902637561e-05, -3.0356514059e-04, 1.0633899309e-05, 3.0394396034e-04, 1.9670968373e-05, -2.9975836205e-04, -4.9246256601e-05, 2.9098536633e-04, 7.7287322618e-05, -2.7773165449e-04, -1.0296954834e-04, 2.6024198912e-04, 1.2546789241e-04, -2.3890642316e-04, -1.4397942062e-04, 2.1426257638e-04, 1.5774072048e-04, -1.8701260395e-04, -1.6608277526e-04, 1.5797895776e-04, 1.6841184996e-04, -1.2813727031e-04, -1.6426471000e-04, 9.8588143147e-05, 1.5332744520e-04, -7.0542628406e-05, -1.3546008304e-04, 4.5300839560e-05, 1.1071725364e-04, -2.4229020039e-05, -7.9369052812e-05, 8.7304172102e-06, 4.1917176549e-05, -2.1359733143e-07, 8.9154509076e-07, 5.5684732341e-08, -4.8058241136e-05, -9.5645259336e-06, 9.8329206660e-05, 2.9936102142e-05, -1.5021007475e-04, -6.2242301782e-05, 2.0192191733e-04, 1.0731658070e-04, -2.5149550419e-04, -1.6578326860e-04, 2.9674068373e-04, 2.3798728777e-04, -3.3528568300e-04, -3.2395737368e-04, 3.6461135551e-04, 4.2336900056e-04, -3.8209378607e-04, -5.3551415119e-04, 3.8504970522e-04, 6.5927338649e-04, -3.7078922152e-04, -7.9309506402e-04, 3.3667193144e-04, 9.3497896102e-04, -2.8016982000e-04, -1.0824689884e-03, 1.9893308743e-04, 1.2326502672e-03, -9.0878613994e-05, -1.3822129737e-03, -4.5837974552e-05, 1.5273385480e-03, 2.1260732950e-04, -1.6638594057e-03, -4.1039456333e-04, 1.7872423998e-03, 6.3965308957e-04, -1.8926390374e-03, -9.0026229113e-04, 1.9749403181e-03, 1.1914685776e-03, -2.0288427900e-03, -1.5118359800e-03, 2.0489193605e-03, 1.8592017593e-03, -2.0296985241e-03, -2.2306418522e-03, 1.9657466867e-03, 2.6224420938e-03, -1.8517561904e-03, -3.0300774686e-03, 1.6826310385e-03, 3.4481615491e-03, -1.4536910901e-03, -3.8706427244e-03, 1.1605007565e-03, 4.2905210198e-03, -7.9922943565e-04, -4.7000627636e-03, 3.6663473842e-04, 5.0907886400e-03, 1.3984314661e-04, -5.4535086079e-03, -7.2199912365e-04, 5.7783632367e-03, 1.3807863999e-03, -6.0548725413e-03, -2.1162519900e-03, 6.2719834173e-03, 2.9274807422e-03, -6.4181164733e-03, -3.8125541134e-03, 6.4812022373e-03, 4.7685227949e-03, -6.4486968344e-03, -5.7914021945e-03, 6.3074824296e-03, 6.8758951772e-03, -6.0443194080e-03, -8.0160498087e-03, 5.6450544953e-03, 9.2046166151e-03, -5.0949732998e-03, -1.0433335135e-02, 4.3784949509e-03, 1.1692940816e-02, -3.4788525138e-03, -1.2973180685e-02, 2.3776290322e-03, 1.4262819466e-02, -1.0540840397e-03, -1.5549625231e-02, -5.1582854228e-04, 1.6820307587e-02, 2.3608884408e-03, -1.8060380987e-02, -4.5167139049e-03, 1.9253907146e-02, 7.0289490089e-03, -2.0383027139e-02, -9.9584985259e-03, 2.1425861759e-02, 1.3387045991e-02, -2.2357498376e-02, -1.7432326004e-02, 2.3143905095e-02, 2.2266759654e-02, -2.3736590026e-02, -2.8154588587e-02, 2.4059190953e-02, 3.5521273283e-02, -2.3977726022e-02, -4.5094967820e-02, 2.3227320643e-02, 5.8224572211e-02, -2.1205329319e-02, -7.7692275917e-02, 1.6266130623e-02, 1.1018596226e-01, -2.5468688834e-03, -1.7594411784e-01, -5.2552158152e-02, 3.6050095823e-01, 5.9743685330e-01, 3.6050095823e-01, -5.2552158152e-02, -1.7594411784e-01, -2.5468688834e-03, 1.1018596226e-01, 1.6266130623e-02, -7.7692275917e-02, -2.1205329319e-02, 5.8224572211e-02, 2.3227320643e-02, -4.5094967820e-02, -2.3977726022e-02, 3.5521273283e-02, 2.4059190953e-02, -2.8154588587e-02, -2.3736590026e-02, 2.2266759654e-02, 2.3143905095e-02, -1.7432326004e-02, -2.2357498376e-02, 1.3387045991e-02, 2.1425861759e-02, -9.9584985259e-03, -2.0383027139e-02, 7.0289490089e-03, 1.9253907146e-02, -4.5167139049e-03, -1.8060380987e-02, 2.3608884408e-03, 1.6820307587e-02, -5.1582854228e-04, -1.5549625231e-02, -1.0540840397e-03, 1.4262819466e-02, 2.3776290322e-03, -1.2973180685e-02, -3.4788525138e-03, 1.1692940816e-02, 4.3784949509e-03, -1.0433335135e-02, -5.0949732998e-03, 9.2046166151e-03, 5.6450544953e-03, -8.0160498087e-03, -6.0443194080e-03, 6.8758951772e-03, 6.3074824296e-03, -5.7914021945e-03, -6.4486968344e-03, 4.7685227949e-03, 6.4812022373e-03, -3.8125541134e-03, -6.4181164733e-03, 2.9274807422e-03, 6.2719834173e-03, -2.1162519900e-03, -6.0548725413e-03, 1.3807863999e-03, 5.7783632367e-03, -7.2199912365e-04, -5.4535086079e-03, 1.3984314661e-04, 5.0907886400e-03, 3.6663473842e-04, -4.7000627636e-03, -7.9922943565e-04, 4.2905210198e-03, 1.1605007565e-03, -3.8706427244e-03, -1.4536910901e-03, 3.4481615491e-03, 1.6826310385e-03, -3.0300774686e-03, -1.8517561904e-03, 2.6224420938e-03, 1.9657466867e-03, -2.2306418522e-03, -2.0296985241e-03, 1.8592017593e-03, 2.0489193605e-03, -1.5118359800e-03, -2.0288427900e-03, 1.1914685776e-03, 1.9749403181e-03, -9.0026229113e-04, -1.8926390374e-03, 6.3965308957e-04, 1.7872423998e-03, -4.1039456333e-04, -1.6638594057e-03, 2.1260732950e-04, 1.5273385480e-03, -4.5837974552e-05, -1.3822129737e-03, -9.0878613994e-05, 1.2326502672e-03, 1.9893308743e-04, -1.0824689884e-03, -2.8016982000e-04, 9.3497896102e-04, 3.3667193144e-04, -7.9309506402e-04, -3.7078922152e-04, 6.5927338649e-04, 3.8504970522e-04, -5.3551415119e-04, -3.8209378607e-04, 4.2336900056e-04, 3.6461135551e-04, -3.2395737368e-04, -3.3528568300e-04, 2.3798728777e-04, 2.9674068373e-04, -1.6578326860e-04, -2.5149550419e-04, 1.0731658070e-04, 2.0192191733e-04, -6.2242301782e-05, -1.5021007475e-04, 2.9936102142e-05, 9.8329206660e-05, -9.5645259336e-06, -4.8058241136e-05, 5.5684732341e-08, 8.9154509075e-07, -2.1359733143e-07, 4.1917176549e-05, 8.7304172102e-06, -7.9369052812e-05, -2.4229020039e-05, 1.1071725364e-04, 4.5300839560e-05, -1.3546008304e-04, -7.0542628406e-05, 1.5332744520e-04, 9.8588143147e-05, -1.6426471000e-04, -1.2813727031e-04, 1.6841184996e-04, 1.5797895776e-04, -1.6608277526e-04, -1.8701260395e-04, 1.5774072048e-04, 2.1426257638e-04, -1.4397942062e-04, -2.3890642316e-04, 1.2546789241e-04, 2.6024198912e-04, -1.0296954834e-04, -2.7773165449e-04, 7.7287322618e-05, 2.9098536633e-04, -4.9246256601e-05, -2.9975836205e-04, 1.9670968373e-05, 3.0394396034e-04, 1.0633899309e-05, -3.0356514059e-04, -4.0902637561e-05, 2.9876248513e-04, 7.0423921070e-05, -2.8978124284e-04, -9.8554828406e-05, 2.7695526551e-04, 1.2472986538e-04, -2.6069232784e-04, -1.4846911541e-04, 2.4145699519e-04, 1.6937935987e-04, -2.1976389992e-04, -1.8717315606e-04, 1.9613879988e-04, 2.0164295580e-04, -1.7112681186e-04, -2.1267575306e-04, 1.4526870106e-04, 2.2024487201e-04, -1.1908891324e-04, -2.2440402737e-04, 9.3083766880e-05, 2.2527905946e-04, -6.7712424724e-05, -2.2305979018e-04, 4.3388540331e-05, 2.1799027829e-04, -2.0474377462e-05, -2.1035949362e-04, -7.2469728068e-07, 2.0048996784e-04, 1.9962162126e-05, -1.8872803133e-04, -3.7052151243e-05, 1.7543162504e-04, 5.1863672862e-05, -1.6097032297e-04, -6.4331942666e-05, 1.4570184837e-04, 7.4442015036e-05, -1.2997378627e-04, -8.2230121207e-05, 1.1411435016e-04, 8.7778099147e-05, -9.8426582324e-05, -9.1208028784e-05, 8.3182977615e-05, 9.2675515616e-05, -6.8622152833e-05, -9.2363424425e-05, 5.4946101683e-05, 9.0474987984e-05, -4.2319264614e-05, -8.7228024371e-05, 3.0867318870e-05, 8.2847991428e-05, -2.0678149910e-05, -7.7562514342e-05, 1.1802029691e-05, 7.1592951923e-05, -4.2590985594e-06, -6.5156848727e-05, -1.9659814241e-06, 5.8456294840e-05, 6.9152844262e-06, -5.1677456070e-05, -1.0655155484e-05, 4.4987430871e-05, 1.3272108299e-05, -3.8532416868e-05, -1.4869088240e-05, 3.2435989363e-05, 1.5561105341e-05, -2.6798566084e-05, -1.5471333700e-05, 2.1697150713e-05, 1.4726895083e-05, -1.7186393143e-05, -1.3455845078e-05, 1.3299174052e-05, 1.1783610692e-05, -1.0048404030e-05, -9.8308154538e-06, 7.4272860215e-06, 7.7079974544e-06, -5.4153975382e-06, -5.5180087231e-06, 3.9770466729e-06, 3.3515646366e-06, -3.0653879786e-06, -1.2868396408e-06, 2.6247343291e-06, -6.1127551357e-07, -2.5932018757e-06, 2.2911751746e-06, 2.9048726877e-06, -3.7145535560e-06, -3.4921305935e-06, 4.8558404072e-06, 4.2875700188e-06, -5.7016749208e-06, -5.2261624079e-06, 6.2495174910e-06, 6.2465071930e-06, -6.5066660743e-06, -7.2923194553e-06, 6.4885530044e-06, 8.3126383806e-06, -6.2187649526e-06, -9.2645864987e-06, 5.7253291919e-06, 1.0111810348e-05, -5.0407409059e-06, -1.0825554933e-05, 4.2001905382e-06, 1.1384548678e-05, -3.2402837230e-06, -1.1774887356e-05, 2.1976691450e-06, 1.1989500776e-05, -1.1080294379e-06, -1.2027655248e-05, 5.0764673656e-09, 1.1894192377e-05, 1.0800930859e-06, -1.1598974212e-05, -2.1198565611e-06, 1.1155862208e-05, 3.0903891146e-06, -1.0581975595e-05, -3.9721441677e-06, 9.8964531020e-06, 4.7493140703e-06, -9.1205837492e-06, -5.4109071995e-06, 8.2760543576e-06, 5.9499175293e-06, -7.3846392061e-06, -6.3632680210e-06, 6.4675064692e-06, 6.6514585653e-06, -5.5447232220e-06, -6.8182526351e-06, 4.6347267011e-06, 6.8701868556e-06, -3.7539939935e-06, -6.8161252774e-06, 2.9167305358e-06, 6.6666874915e-06, -2.1348157389e-06, -6.4338873737e-06, 1.4176102267e-06, 6.1305800188e-06, -7.7201393798e-07, -5.7700961445e-06, 2.0237226313e-07, 5.3655378184e-06, 2.8897639035e-07, -4.9298766655e-06, -7.0193371176e-07, 4.4753338337e-06, 1.0382380087e-06, -4.0131979608e-06, -1.3012333868e-06, 3.5536079574e-06, 1.4955690485e-06, -3.1054449656e-06, -1.6269525965e-06, 2.6762188358e-06, 1.7018573100e-06, -2.2720424370e-06, -1.7272773341e-06, 1.8975988987e-06, 1.7104220953e-06, -1.5562502454e-06, -1.6585436949e-06, 1.2500794491e-06, 1.5787101457e-06, -9.8003095819e-07, -1.4776973846e-06, 7.4593102033e-07, 1.3616983349e-06, -5.4680286615e-07, -1.2363732525e-06, 3.8090322322e-07, 1.1067087347e-06, -2.4590456526e-07, -9.7698241404e-07, 1.3903944093e-07, 8.5073459712e-07, -5.7258660379e-08, -7.3078881085e-07, -2.6449990600e-09, 6.1927450281e-07, 4.3912141526e-08, -5.1768189064e-07, -6.9728273535e-08, 4.2690052017e-07, 8.3113354043e-08, -3.4731055047e-07, -8.6868329262e-08, 2.7884886851e-07, 8.3513736086e-08, -2.2110585899e-07, -7.5285999914e-08, 1.7336089207e-07, 6.4069374884e-08, -1.3470358155e-07, -5.1424493976e-08, 1.0408565660e-07, 3.8587584901e-08, -8.0388121559e-08, -2.6490103688e-08, 6.2474530539e-08, 1.5780611408e-08, -4.9242190366e-08, -6.8593101817e-09, 3.9658707043e-08, -8.7493265118e-11, -3.2792961253e-08, 5.0459558021e-09, 2.7829908603e-08, -8.1423949947e-09, -2.4087477079e-08, 9.6024488521e-09, 2.1018216881e-08, -9.7183443203e-09}
  COEFFICIENT_WIDTH 24
  QUANTIZATION Quantize_Only
  BESTPRECISION true
  FILTER_TYPE Decimation
  DECIMATION_RATE 2
  NUMBER_CHANNELS 16
  NUMBER_PATHS 1
  SAMPLE_FREQUENCY 0.768
  CLOCK_FREQUENCY 122.88
  OUTPUT_ROUNDING_MODE Convergent_Rounding_to_Even
  OUTPUT_WIDTH 26
  HAS_ARESETN true
} {
  S_AXIS_DATA conv_0/M_AXIS
  aclk /pll_0/clk_out1
  aresetn /rst_0/peripheral_aresetn
}

# Create axis_dwidth_converter
cell xilinx.com:ip:axis_dwidth_converter conv_1 {
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 4
  M_TDATA_NUM_BYTES 64
} {
  S_AXIS fir_0/M_AXIS_DATA
  aclk /pll_0/clk_out1
  aresetn /rst_0/peripheral_aresetn
}

# Create axis_broadcaster
cell xilinx.com:ip:axis_broadcaster bcast_8 {
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  M_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 64
  M_TDATA_NUM_BYTES 8
  NUM_MI 8
  M00_TDATA_REMAP {tdata[23:16],tdata[39:32],tdata[47:40],tdata[55:48],16'b0000000000000000,tdata[7:0],tdata[15:8]}
  M01_TDATA_REMAP {tdata[87:80],tdata[103:96],tdata[111:104],tdata[119:112],16'b0000000000000000,tdata[71:64],tdata[79:72]}
  M02_TDATA_REMAP {tdata[151:144],tdata[167:160],tdata[175:168],tdata[183:176],16'b0000000000000000,tdata[135:128],tdata[143:136]}
  M03_TDATA_REMAP {tdata[215:208],tdata[231:224],tdata[239:232],tdata[247:240],16'b0000000000000000,tdata[199:192],tdata[207:200]}
  M04_TDATA_REMAP {tdata[279:272],tdata[295:288],tdata[303:296],tdata[311:304],16'b0000000000000000,tdata[263:256],tdata[271:264]}
  M05_TDATA_REMAP {tdata[343:336],tdata[359:352],tdata[367:360],tdata[375:368],16'b0000000000000000,tdata[327:320],tdata[335:328]}
  M06_TDATA_REMAP {tdata[407:400],tdata[423:416],tdata[431:424],tdata[439:432],16'b0000000000000000,tdata[391:384],tdata[399:392]}
  M07_TDATA_REMAP {tdata[471:464],tdata[487:480],tdata[495:488],tdata[503:496],16'b0000000000000000,tdata[455:448],tdata[463:456]}
} {
  S_AXIS conv_1/M_AXIS
  aclk /pll_0/clk_out1
  aresetn /rst_0/peripheral_aresetn
}

for {set i 0} {$i <= 7} {incr i} {

  # Create fifo_generator
  cell xilinx.com:ip:fifo_generator fifo_generator_$i {
    PERFORMANCE_OPTIONS First_Word_Fall_Through
    INPUT_DATA_WIDTH 64
    INPUT_DEPTH 1024
    OUTPUT_DATA_WIDTH 32
    OUTPUT_DEPTH 2048
    READ_DATA_COUNT true
    READ_DATA_COUNT_WIDTH 12
  } {
    clk /pll_0/clk_out1
    srst slice_0/dout
  }

  # Create axis_fifo
  cell pavel-demin:user:axis_fifo fifo_$i {
    S_AXIS_TDATA_WIDTH 64
    M_AXIS_TDATA_WIDTH 32
  } {
    S_AXIS bcast_8/M0${i}_AXIS
    FIFO_READ fifo_generator_$i/FIFO_READ
    FIFO_WRITE fifo_generator_$i/FIFO_WRITE
    aclk /pll_0/clk_out1
  }

  # Create axi_axis_reader
  cell pavel-demin:user:axi_axis_reader reader_$i {
    AXI_DATA_WIDTH 32
  } {
    S_AXIS fifo_$i/M_AXIS
    aclk /pll_0/clk_out1
    aresetn /rst_0/peripheral_aresetn
  }

}