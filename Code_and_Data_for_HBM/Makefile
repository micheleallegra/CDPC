CC=g++
CFLAGS=-O3 -fopenmp 

brain_cluster:  src/brain_cluster.o src/FT_intensity.o src/DFT.o  src/generate_decision_graph.o src/compute_clusters.o
	$(CC) $(CFLAGS) -o brain_cluster.exe src/brain_cluster.o src/FT_intensity.o src/DFT.o  src/generate_decision_graph.o src/compute_clusters.o

