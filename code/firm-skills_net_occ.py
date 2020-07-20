import csv
from sklearn.metrics.pairwise import cosine_similarity
import numpy as np

outfile = open('/Users/matthewcorritore/Dropbox/BG_Skills/temp/firm_skill_net_occ.csv','w')
write = csv.writer(outfile)

#this reads and loops through each row of the input csv file
with open('/Users/matthewcorritore/Dropbox/BG_Skills/temp/org_soc_combined.csv', 'r') as infile:
    read = csv.reader(infile, delimiter = ',')

	#this command just skips past the first line of a csv file, which typically contains a header with variable names
    next(read)

	#now we loop through each row in the csv file
    for row in read:
        orgid = row[607]
        soc = row[608]
        year = row[609]
        num_jobs = row[610]

        vec1 = np.array([row[0:607]]).astype(np.float)
        vec2 = np.array([row[611:len(row)]]).astype(np.float)

        net_mean_occ = np.subtract(vec1, vec2)

        #net_mean_occ = net_mean_occ.tolist()

        #print(net_mean_occ)

        ids = np.array([orgid,soc,year,num_jobs])

        #ids.extend(net_mean_occ)

        toWrite = np.append(ids,net_mean_occ)

        toWrite = toWrite.tolist()

        #toWrite = [orgid,soc,year,num_jobs,net_mean_occ]
        write.writerow(toWrite)
infile.close()
