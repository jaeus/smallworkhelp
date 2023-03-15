import csv
import xlsxwriter as xw
from tkinter import filedialog, Tk
import os
from prettytable import PrettyTable

# tkinter setup
root = Tk()
root.withdraw()

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
    dtset = []
    for pn in bomdata[0][0][1:]:
        if pn not in bomdata[1][0][1:]:
            dtset.append(['D', '', '', '', '', pn, bomdata[0][1][bomdata[0][0].index(pn)]])
        elif bomdata[0][1][bomdata[0][0].index(pn)] != bomdata[1][1][bomdata[1][0].index(pn)]:
            dtset.append(['C', '', '', '', '', pn, bomdata[1][1][bomdata[1][0].index(pn)]])
    for pn in bomdata[1][0][1:]:
        if pn not in bomdata[0][0][1:]:
            dtset.append(['A', '', '', '', '', pn, bomdata[1][1][bomdata[1][0].index(pn)]])
    for mbr in dtset:
        dtset.sort(key=lambda m: m[0])
    dtset.insert(0, ['', '', '', '', bomdata[0][0][0], '', ''])        
    
    # rusult displaying and saving preparation
    colname = ['CODE', ' ', 'OLD PARENT NO.', '  ', 'PARENT NO.', 'COMPONENT NO.', 'QUANTITY']
    pttbl = PrettyTable()
    pttbl.field_names = colname
    psworkbook = xw.Workbook('Product Structure for ' + bomdata[0][0][0] + '.xlsx')
    pssheet = psworkbook.add_worksheet()
    for colno in range(len(colname)):
        pssheet.write(0, colno, colname[colno])
    
    # inputting data
    for mbrno in dtset:
        pttbl.add_row(mbrno)
        for mbr in mbrno:
            pssheet.write(dtset.index(mbrno)+1, mbrno.index(mbr), mbr)
            
    # printing result
    print(pttbl)
    for w in range(len(colname)):
        pssheet.set_column(w, w, len(colname[w])+3)
    psworkbook.close()
    asmpn = input('\nPRESS <ENTER> TO EXIT')
