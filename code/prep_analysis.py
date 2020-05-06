#this file imports jobidXskillcluster_wage.csv and preps for the AKM analysis

import pandas as pd
import numpy as np
from sklearn.linear_model import LinearRegression
from scipy import sparse

df = pd.read_csv("~/bg_skills/BGxAKM/temp/jobidXskillcluster_wage.csv",
                 usecols=['bgtjobid',
                          'soc',
                          'year',
                          'skillcluster',
                          'minsalary',
                          'maxsalary',
                          'msa',
                          'edu',
                          'exp',
                          'fuzzyemployer'],
                 dtype={'bgtjobid':'int64',
                         'soc':'str',
                         'year':'int16',
                         'skillcluster':'str',
                         'minsalary':'float64',
                         'maxsalary':'float64',
                         'msa':'int32',
                         'fuzzyemployer':'str'})

#drop if various values are missing
df = df.dropna(subset=['bgtjobid',
                       'soc',
                       'year',
                       'skillcluster',
                       'minsalary',
                       'maxsalary',
                       'msa',
                       'fuzzyemployer'])
df = df[df['msa']!=-999]

#recode missing edu and exp values to 0 per Kahn/Deming
df['edu'].fillna(0, inplace = True) 
df['exp'].fillna(0, inplace = True) 

#create numeric soc6 var
df['soc'] = df['soc'].str.replace('-','', regex=False)

#create wage var
df['ln_avgwage'] = np.log((df['minsalary'] + df['maxsalary'])*(0.5))
df['ln_minwage'] = np.log(df['minsalary'])
df['ln_maxwage'] = np.log(df['maxsalary'])

#assign unique orgid
df['orgid'] = df.groupby(['fuzzyemployer']).ngroup()

#assign unique skillid
df['skillclusterid'] = df.groupby(['skillcluster']).ngroup()

#drop any duplicates
df = df.drop_duplicates(subset=['bgtjobid','skillclusterid'])

#save dataframe as a pkl that can easily be reloaded
#df.to_csv('~/bg_skills/BGxAKM/temp/wage_long.csv',index=False)
#df.to_pickle('~/bg_skills/BGxAKM/temp/wage_long.pkl')

#COMMENT OUT LATER
#df = pd.read_csv('~/bg_skills/BGxAKM/temp/wage_long.csv',nrows=1000000)

#save orgid orgname crosswalk
orgid_cross = df[['orgid','fuzzyemployer']].drop_duplicates()
orgid_cross.to_csv('~/bg_skills/BGxAKM/temp/orgid_cross.csv',index=False)
del df['fuzzyemployer']

#save skillid skillcluster crosswalk
skillclusterid_cross = df[['skillclusterid','skillcluster']].drop_duplicates()
skillclusterid_cross.to_csv('~/bg_skills/BGxAKM/temp/skillclusterid_cross.csv',index=False)
del df['skillcluster']


years = [2010,2011,2012,2013,2014,2015,2016,2017,2018]

for yr in years:

    df_sub = df[df['year']==yr]
    #del df   #comment this out later -- just trying to fit the 2018 model into memory

    print(df_sub.shape)

    #drop firms in only one msa or w only one soc code
    msa_per_firm = df_sub[['orgid','msa']].drop_duplicates()
    msa_per_firm = msa_per_firm.groupby(['orgid'], as_index=False).count()
    msa_per_firm = msa_per_firm.rename(columns={"msa":"msa_per_firm"})
    msa_per_firm = msa_per_firm[msa_per_firm['msa_per_firm'] > 1]
    df_sub = df_sub.merge(msa_per_firm, on='orgid',how='right')
    del df_sub['msa_per_firm']
    del msa_per_firm

    soc_per_firm = df_sub[['orgid','soc']].drop_duplicates()
    soc_per_firm = soc_per_firm.groupby(['orgid'], as_index=False).count()
    soc_per_firm = soc_per_firm.rename(columns={"soc":"soc_per_firm"})
    soc_per_firm = soc_per_firm[soc_per_firm['soc_per_firm'] > 1]
    df_sub = df_sub.merge(soc_per_firm, on='orgid',how='right')
    del df_sub['soc_per_firm']
    del soc_per_firm

    #drop firms with less than 10 job ads
    ads_per_firm = df_sub[['bgtjobid','orgid']].drop_duplicates()
    ads_per_firm = ads_per_firm.groupby(['orgid'], as_index=False).count()
    ads_per_firm = ads_per_firm.rename(columns={"bgtjobid":"ads_per_firm"})
    ads_per_firm = ads_per_firm[ads_per_firm['ads_per_firm'] > 10]    
    df_sub = df_sub.merge(ads_per_firm, on='orgid',how='right')
    del df_sub['ads_per_firm']
    del ads_per_firm
    
    #drop skills that appear less than 10 times
    skill_freq = df_sub[['bgtjobid','skillclusterid']].drop_duplicates()
    skill_freq = skill_freq.groupby(['skillclusterid'], as_index=False).count()
    skill_freq = skill_freq.rename(columns={"bgtjobid":"skill_freq"})
    skill_freq = skill_freq[skill_freq['skill_freq'] > 10]    
    df_sub = df_sub.merge(skill_freq, on='skillclusterid',how='right')
    del df_sub['skill_freq']
    del skill_freq
 
    #create dummies
    i_soc = pd.get_dummies(df_sub['soc'],sparse=True)
    soc_names = pd.DataFrame(i_soc.columns.values)
    num_soc = i_soc.shape[1]
    i_soc = sparse.coo_matrix(i_soc)

    i_org = pd.get_dummies(df_sub['orgid'],sparse=True)
    org_names = pd.DataFrame(i_org.columns.values)
    num_org = i_org.shape[1]
    i_org = sparse.coo_matrix(i_org)

    i_skill = pd.get_dummies(df_sub['skillclusterid'],sparse=True)
    skill_names = pd.DataFrame(i_skill.columns.values)
    num_skill = i_skill.shape[1]
    i_skill = sparse.coo_matrix(i_skill)

    i_msa = pd.get_dummies(df_sub['msa'],sparse=True)
    msa_names = pd.DataFrame(i_msa.columns.values) 
    num_msa = i_msa.shape[1]
    i_msa = sparse.coo_matrix(i_msa)

    #i_year = pd.get_dummies(df_sub['year'],sparse=True)
    #i_year = sparse.coo_matrix(i_year)

    #edu and exp
    edu = sparse.coo_matrix(df_sub['edu'])
    edu = sparse.coo_matrix.transpose(edu)
    exp = sparse.coo_matrix(df_sub['exp'])
    exp = sparse.coo_matrix.transpose(exp)
    
    #concat
    X = sparse.hstack([i_soc,i_org,i_skill,i_msa,edu,exp])
    #df_concat = pd.concat([i_soc,i_org,i_skill,i_msa,i_year,df['edu'],df['exp']],axis=1)

    #sklearn ols
    y = df_sub['ln_avgwage'].to_numpy()
    #X = sparse.coo_matrix(df_concat)
    #X = df_concat.to_numpy()
    reg = LinearRegression().fit(X,y)

    #save soc,org, and skill coefficients to separate dataframes 
    soc_betas = pd.DataFrame(reg.coef_[0:num_soc])
    soc_betas.rename(columns={0:'soc_FEs'},inplace=True)
    soc_names.rename(columns={0:'soc'},inplace=True)
    soc_FEs = pd.concat([soc_names,soc_betas],axis=1)

    org_betas = pd.DataFrame(reg.coef_[num_soc:(num_soc+num_org)])
    org_betas.rename(columns={0:'org_FEs'},inplace=True)
    org_names.rename(columns={0:'orgid'},inplace=True)
    org_FEs = pd.concat([org_names,org_betas],axis=1)
    
    skill_betas = pd.DataFrame(reg.coef_[(num_soc+num_org):(num_soc+num_org+num_skill)])
    skill_betas.rename(columns={0:'skill_FEs'},inplace=True)
    skill_names.rename(columns={0:'skillclusterid'},inplace=True)
    skill_FEs = pd.concat([skill_names,skill_betas],axis=1)
    
    msa_betas = pd.DataFrame(reg.coef_[(num_soc+num_org+num_skill):(num_soc+num_org+num_skill+num_msa)])
    msa_betas.rename(columns={0:'msa_FEs'},inplace=True)
    msa_names.rename(columns={0:'msa'},inplace=True)
    msa_FEs = pd.concat([msa_names,msa_betas],axis=1)
    
    #merge on the FEs to the final dataframe
    df_sub = df_sub.merge(soc_FEs,on='soc',how='left')
    df_sub = df_sub.merge(org_FEs,on='orgid',how='left')
    df_sub = df_sub.merge(skill_FEs,on='skillclusterid',how='left')
    df_sub = df_sub.merge(msa_FEs,on='msa',how='left')

    #merge on the FEs and coefficients  
    df_sub['intercept'] = reg.intercept_
    df_sub['edu_beta'] = reg.coef_[-2]    
    df_sub['exp_beta'] = reg.coef_[-1]        
    
    df_sub.to_csv('~/bg_skills/BGxAKM/temp/complete_FEs_' + str(yr) + '.csv',index=False)




