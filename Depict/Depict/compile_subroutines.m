mex -v CXXOPTIMFLAGS='-O3 -DNDEBUG' depict_FT_intensity.cpp DFT.cpp
mex -v CXX='$CXX -fopenmp' CXXOPTIMFLAGS='-O3 -DNDEBUG' depict_generate_decision_graph.cpp
mex -v CXX='$CXX -fopenmp' CXXOPTIMFLAGS='-O3 -DNDEBUG' depict_compute_clusters.cpp
