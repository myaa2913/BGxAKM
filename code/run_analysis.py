import pandas as pd
import numpy as np
from sklearn.linear_model import LinearRegression
from scipy import sparse

df = pd.read_csv('master_analytic.csv',usecols=['bgtjobid',
                                                                        'soc',
                                                                        'year',
                                                                        'msa',
                                                                        'edu',
                                                                        'exp',
                                                                        'orgid',
                                                                        'bundleid',
                                                                        'ln_wage'],
                                                               dtype={'bgtjobid':'int64',
                                                                      'soc': 'int32',
                                                                      'year':'int16',
                                                                      'msa':'int32',
                                                                      'edu':'float16',
                                                                      'exp':'float16',
                                                                      'orgid':'int32',
                                                                      'bundleid':'int32',
                                                                      'ln_wage':'float64'})

years = [2010,2011,2012,2013,2014,2015,2016,2017,2018]

for yr in years:

    df_sub = df[df['year']==yr]

    #create dummies
    i_soc = pd.get_dummies(df_sub['soc'],sparse=True)
    soc_names = pd.DataFrame(i_soc.columns.values)
    num_soc = i_soc.shape[1]
    i_soc = sparse.coo_matrix(i_soc)

    i_org = pd.get_dummies(df_sub['orgid'],sparse=True)
    org_names = pd.DataFrame(i_org.columns.values)
    num_org = i_org.shape[1]
    i_org = sparse.coo_matrix(i_org)

    i_skill = pd.get_dummies(df_sub['bundleid'],sparse=True)
    skill_names = pd.DataFrame(i_skill.columns.values)
    num_skill = i_skill.shape[1]
    i_skill = sparse.coo_matrix(i_skill)

    i_msa = pd.get_dummies(df_sub['msa'],sparse=True)
    i_msa = sparse.coo_matrix(i_msa)
    i_year = pd.get_dummies(df_sub['year'],sparse=True)
    i_year = sparse.coo_matrix(i_year)


    #concat
    X = sparse.hstack([i_soc,i_org,i_skill,i_msa,i_year])
    #df_concat = pd.concat([i_soc,i_org,i_skill,i_msa,i_year,df['edu'],df['exp']],axis=1)

    #sklearn ols
    y = df_sub['ln_wage'].to_numpy()
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
    skill_names.rename(columns={0:'bundleid'},inplace=True)
    skill_FEs = pd.concat([skill_names,skill_betas],axis=1)

    #merge on the FEs to the final dataframe
    df_final = df_sub[['year','soc','orgid','bundleid']]
    df_final = df_final.drop_duplicates()

    print(df_final.shape)
    df_final = df_final.merge(soc_FEs,on='soc',how='left')
    print(df_final.shape)
    df_final = df_final.merge(org_FEs,on='orgid',how='left')
    print(df_final.shape)
    df_final = df_final.merge(skill_FEs,on='bundleid',how='left')
    print(df_final.shape)
    
    df_final.to_csv('complete_FEs_' + str(yr) + '.csv',index=False)
