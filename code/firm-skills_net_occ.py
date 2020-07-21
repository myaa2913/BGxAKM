import csv
from sklearn.metrics.pairwise import cosine_similarity
import numpy as np

outfile = open('firm_skill_net_occ.csv','w')
write = csv.writer(outfile)

#this reads and loops through each row of the input csv file
counter = 0
header = None
with open('org_soc_combined.csv', 'r') as infile:
    read = csv.reader(infile, delimiter = ',')

    #now we loop through each row in the csv file
    for row in read:
        counter+=1

        if counter==1:
            header = row[0:634]
            write.writerow(header)
            
        if counter>1:

            orgid = row[634]
            soc = row[635]
            year = row[636]
            num_jobs = row[637]

            vec1 = np.array([row[0:634]]).astype(np.float)
            vec2 = np.array([row[638:len(row)]]).astype(np.float)

            net_mean_occ = np.subtract(vec1, vec2)
            net_mean_occ = np.absolute(net_mean_occ)

            ids = np.array([orgid,soc,year,num_jobs])

            toWrite = np.append(net_mean_occ.ravel(),ids)

            write.writerow(toWrite)
infile.close()
