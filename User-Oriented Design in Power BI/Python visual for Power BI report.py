# The following code to create a dataframe and remove duplicated rows is always executed and acts as a preamble for your script: 

# dataset = pandas.DataFrame(area_name, period_date, value)
# dataset = dataset.drop_duplicates()

# Paste or type your script code here:

import matplotlib.pyplot as plt
import datetime as dt
dataset['period_date'] = [dt.datetime.strptime(d, '%Y-%m-%dT00:00:00.0000000').date() for d in dataset['period_date']]
fig, ax = plt.subplots()
for key, grp in dataset.groupby(['area_name']):
    ax = grp.plot(ax=ax, kind='line', x='period_date', y='value', label=key)
plt.legend(loc='best')
plt.show()