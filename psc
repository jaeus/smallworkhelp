import csv
from tkinter import filedialog, Tk
import os
from prettytable import PrettyTable

# tkinter setup
root = Tk()
root.withdraw()

# rusult displaying preparation
pttbl = PrettyTable()
pttbl.field_names = ['CODE', '(EMPTY_1)', 'OLD PARENT NO.', '(EMPTY_2)', 'PARENT NO.', 'COMPONENT NO.', 'QUANTITY']

# loading BOMs
bomdata = []
for titletext in ['OLD BOM', 'NEW BOM']:
    root.fn = filedialog.askopenfilename(initialdir = (os.getcwd()), title = ('SELECT THE ' + titletext))
    if len(root.fn) == 0:
        print('FILE NOT SELECTED')
        break
    with open(root.fn, newline='') as rawdata:
        tempdata = csv.reader(rawdata, delimiter=',')
        bomtemp = list(tempdata)
        rawdata.close()
    bomtemp[0][0] = bomtemp[0][0].split('"')[1]
    
    eachbom = []
    for colno in [1,3]:
        eachcol = []
        for eachrow in bomtemp:
            # add items if level is only 0 or 1
            if 'skel' in eachrow[1] or eachrow[0] not in ["0", "1"]:
                continue
            if colno == 1:
                eachcol.append(eachrow[colno].split('.')[0])
            else:
                # BOM revision information
                if bomtemp.index(eachrow) != 1:
                    eachcol.append(eachrow[colno])
                else:
                    eachcol.append(eachrow[2].split('.')[0]) if eachrow[2].split('.')[0][0] != '-' else eachcol.append('-')
        eachbom.append(eachcol)
    bomdata.append(eachbom)
if len(bomdata) == 2 and bomdata[0][0][0] != bomdata[1][0][0]:
    print("BOM NOT MATCHING")
elif len(root.fn) != 0:
    pttbl.add_row(['', '', '', '', bomdata[0][0][0], '', ''])
    for pn in bomdata[0][0][1:]:
        if pn not in bomdata[1][0][1:]:
            pttbl.add_row(['D', '', '', '', '', pn, bomdata[0][1][bomdata[0][0].index(pn)]])
        elif bomdata[0][1][bomdata[0][0].index(pn)] != bomdata[1][1][bomdata[1][0].index(pn)]:
            pttbl.add_row(['C', '', '', '', '', pn, bomdata[1][1][bomdata[1][0].index(pn)]])
    for pn in bomdata[1][0][1:]:
        if pn not in bomdata[0][0][1:]:
            pttbl.add_row(['A', '', '', '', '', pn, bomdata[1][1][bomdata[1][0].index(pn)]])
    print(pttbl)
    with open('Product Structure for ' + bomdata[0][0][0] + '.csv', 'w', newline='') as output:
        output.write(pttbl.get_csv_string())
asmpn = input('\nPRESS <ENTER> TO EXIT')
