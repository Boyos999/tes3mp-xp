import json
import argparse

parser = argparse.ArgumentParser(description='take a filename input')
parser.add_argument('file', help='Give an input json file.')

args = parser.parse_args()

newdata = {}

with open (args.file) as f:
    data = json.load(f)
    
for record in data:
    print(record['quest'] + str(record['index']))
    newdata[record['quest'].lower()+"_"+str(record['index'])] = {'isend': bool('true')}
    
with open('out'+args.file, 'w') as json_file:
    json.dump(newdata,json_file)