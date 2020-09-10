import json
from collections import Counter
# pip install pandas openpyxl 
from pandas import DataFrame, ExcelWriter

with open('signalfx-collectd.log','r') as file1, open('metrices.log','w') as file2: 

# reading each line from signalfx-collectd.log file 
 for line in file1.readlines(): 
   # reading all lines that do not begin with "2020" 
   if not (line.startswith('[2020')): 
     file2.write(line) 
  
list = []

# Create list of 'type.type_instance' values.
with open('metrices.log') as f:
  for line in f:
    obj = json.loads(line)
    list.append(obj[0]["type"] + "." + obj[0]["type_instance"].partition('[')[0])

# Count occurances of each metrics.
cnt = Counter(list)

# Save data to Excel with Pandas DF.
myDF = DataFrame(cnt, index=[0])
writer = ExcelWriter('Metrices.xlsx')
myDF.to_excel(writer)
writer.save()  

