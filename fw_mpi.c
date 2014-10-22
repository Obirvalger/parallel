#include <stdio.h>
#include "mpi.h"
#include <stdlib.h>
#define MASTER 0
#define WORKTAG 1
#define DIETAG 2
#define n 10
 
int dist[n][n] = {{0,-1,6,6,3,-1,-1,3,5,5},{-1,0,6,3,6,-1,-1,-1,5,6},{-1,-1,0,-1,3,6,-1,6,6,4},{4,3,-1,0,-1,6,4,3,-1,-1},{-1,-1,3,5,0,-1,6,4,-1,-1},{-1,-1,4,3,4,0,-1,4,4,6},{6,-1,-1,-1,-1,-1,0,4,5,6},{6,4,5,-1,-1,-1,6,0,-1,6},{-1,4,6,3,5,-1,-1,5,0,4},{3,-1,4,4,-1,4,6,-1,-1,0}};
 
void printDist() {
    int i, j;
    for (i = 0; i < n; ++i) {
        for (j = 0; j < n; ++j)
            printf("%d ", dist[i][j]);
        printf("\n");
    }
}
 
int main(int argc, char *argv[]) {
 
    int my_rank, num_procs, slice, yp = 0;
    MPI_Status status;
    MPI_Init(&argc,&argv);
    MPI_Comm_size(MPI_COMM_WORLD,&num_procs);
    MPI_Comm_rank(MPI_COMM_WORLD,&my_rank);
 
    yp = n % (num_procs - 1);
    slice = (n - yp) / (num_procs - 1);
 
    if (my_rank == MASTER) {
      double t1,t2;
      int disable = 0,t = 3, i = 0, j = 0;
      int result[t];
      t1 = MPI_Wtime();
         for(i=1;i<num_procs;i++)
         MPI_Send(&dist,n*n,MPI_INT,i,WORKTAG,MPI_COMM_WORLD);
 
      do {
         MPI_Recv(&result,t,MPI_INT,MPI_ANY_SOURCE,MPI_ANY_TAG,MPI_COMM_WORLD,&status);
         if (status.MPI_TAG == DIETAG)
            disable++;
         else
            if (dist[result[1]][result[2]] == -1 || (result[0] != -1 && dist[result[1]][result[2]] > result[0]))
                dist[result[1]][result[2]]=result[0];
      } while (disable < num_procs-1);
      t2 = MPI_Wtime();
      printf("%f\n", t2 - t1);
      printDist();
    } else {
 
        int i, j, k, t = 3;
        int out[t];
        MPI_Recv(&dist,n*n,MPI_INT,MASTER,MPI_ANY_TAG,MPI_COMM_WORLD,&status);
        if(my_rank+1!=num_procs)
            yp=0;
        for (k = slice*(my_rank-1); k < slice*(my_rank-1)+slice+yp; ++k)
            for (i = 0; i < n; ++i)
                for (j = 0; j < n; ++j)
                    if ((dist[i][k] > 0) && (dist[k][j] > 0))
                        if ((dist[i][j] == -1) || (dist[i][k] + dist[k][j] < dist[i][j])){
                            dist[i][j] = dist[i][k] + dist[k][j];
                            out[0]=dist[i][j];
                            out[1]=i;
                            out[2]=j;
                            MPI_Send(&out,t,MPI_INT,MASTER,0,MPI_COMM_WORLD);
                        }
        MPI_Send(0,0,MPI_INT,MASTER,DIETAG,MPI_COMM_WORLD);
    }
 
    MPI_Finalize();
 
    return 0;
}
