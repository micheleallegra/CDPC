mv depict_generate_decision_graph.cpp depict_generate_decision_graph_omp.cpp
mv depict_generate_decision_graph_noomp.cpp depict_generate_decision_graph.cpp
mv depict_compute_clusters.cpp depict_compute_clusters_omp.cpp
mv depict_compute_clusters_noomp.cpp depict_compute_clusters.cpp
mex -v CXXOPTIMFLAGS='-O3 -DNDEBUG' depict_FT_intensity.cpp DFT.cpp
mex -v CXX='$CXX' CXXOPTIMFLAGS='-O3 -DNDEBUG' depict_generate_decision_graph.cpp
mex -v CXX='$CXX' CXXOPTIMFLAGS='-O3 -DNDEBUG' depict_compute_clusters.cpp
mv depict_generate_decision_graph.cpp depict_generate_decision_graph_noomp.cpp
mv depict_generate_decision_graph_omp.cpp depict_generate_decision_graph.cpp
mv depict_compute_clusters.cpp depict_compute_clusters_noomp.cpp
mv depict_compute_clusters_omp.cpp depict_compute_clusters.cpp
