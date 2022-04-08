import numpy as np
from mpi4py import MPI

comm = MPI.COMM_WORLD
rank = comm.Get_rank()
nprocs = comm.Get_size()

start_time = MPI.Wtime()
if rank == 0:
    sendbuf = np.arange(1, 10000001.0)
    print('Adding numbers from 1 to 10 000 000')

    # count: the size of each sub-task
    ave, res = divmod(sendbuf.size, nprocs)
    count = [ave + 1 if p < res else ave for p in range(nprocs)]
    count = np.array(count)

    # displacement: the starting index of each sub-task
    displ = [sum(count[:p]) for p in range(nprocs)]
    displ = np.array(displ)
else:
    sendbuf = None
    # initialize count on worker processes
    count = np.zeros(nprocs, dtype=np.int)
    displ = None

# broadcast count
comm.Bcast(count, root=0)

# initialize recvbuf on all processes
recvbuf = np.zeros(count[rank])

comm.Scatterv([sendbuf, count, displ, MPI.DOUBLE], recvbuf, root=0)

print('After Scatterv, process {} has data of length:'.format(rank), len(recvbuf))

partial_sum = np.zeros(1)
partial_sum[0] = sum(recvbuf)
print('Partial sum on process {} is:'.format(rank), partial_sum[0])

total_sum = np.zeros(1)
comm.Reduce(partial_sum, total_sum, op=MPI.SUM, root=0)


end_time = MPI.Wtime()

if comm.Get_rank() == 0:
    print('After Reduce, total sum on process 0 is:', total_sum[0])
    print('total time: {} s'.format(end_time - start_time))


# np.random.randint(100, size=100)
