import csv
from sklearn.metrics.pairwise import cosine_similarity
import numpy as np

x = np.array([[0,1,4]])
y = np.array([[1,1,0]])

print(cosine_similarity(x,y))

outfile = open('/Users/matthewcorritore/Dropbox/BG_Skills/temp/cos_sim.csv','w')
header = ['orgid','soc','year','num_jobs','cos_dist']
write = csv.writer(outfile)
write.writerow(header)   #write the header row to the output csv file

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

        vec1 = np.array([row[0:607]])
        vec2 = np.array([row[611:len(row)]])

        cos_dis = 1 - float(cosine_similarity(vec1,vec2))

        toWrite = [orgid,soc,year,num_jobs,cos_dis]
        write.writerow(toWrite)
infile.close()
