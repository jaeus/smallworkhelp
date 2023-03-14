import csv
import xlsxwriter as xw
from tkinter import filedialog, Tk
import os
from prettytable import PrettyTable

# tkinter setup
root = Tk()
root.withdraw()

# rusult displaying preparation
pttbl = PrettyTable()
pttbl.field_names = ['CODE', ' ', 'OLD PARENT NO.', '  ', 'PARENT NO.', 'COMPONENT NO.', 'QUANTITY']

def adddt(func_wb, func_dtset, func_rowno, func_pttbl):
    for func_colno in range(len(func_dtset)):
        func_wb.write(func_rowno, func_colno, func_dtset[func_colno])
    func_pttbl.add_row(func_dtset)
    func_rowno += 1
    return(func_wb, func_rowno, func_pttbl)


# loading BOMs
rowno, bomdata = 0, []
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
    psworkbook = xw.Workbook('Product Structure for ' + bomdata[0][0][0] + '.xlsx')
    pssheet = psworkbook.add_worksheet()
    colname = ['CODE', ' ', 'OLD PARENT NO.', '  ', 'PARENT NO.', 'COMPONENT NO.', 'QUANTITY']
    for colno in range(len(colname)):
        pssheet.write(rowno, colno, colname[colno])
    rowno += 1
    
    dtset = ['', '', '', '', bomdata[0][0][0], '', '']
    pssheet, rowno, pttbl = adddt(pssheet, dtset, rowno, pttbl)
    for pn in bomdata[0][0][1:]:
        if pn not in bomdata[1][0][1:]:
            dtset = ['D', '', '', '', '', pn, bomdata[0][1][bomdata[0][0].index(pn)]]
            pssheet, rowno, pttbl = adddt(pssheet, dtset, rowno, pttbl)
        elif bomdata[0][1][bomdata[0][0].index(pn)] != bomdata[1][1][bomdata[1][0].index(pn)]:
            dtset = ['C', '', '', '', '', pn, bomdata[1][1][bomdata[1][0].index(pn)]]
            pssheet, rowno, pttbl = adddt(pssheet, dtset, rowno, pttbl)

    for pn in bomdata[1][0][1:]:
        if pn not in bomdata[0][0][1:]:
            dtset = ['A', '', '', '', '', pn, bomdata[1][1][bomdata[1][0].index(pn)]]
            pssheet, rowno, pttbl = adddt(pssheet, dtset, rowno, pttbl)
        
    print(pttbl)
for w in range(len(colname)):
    pssheet.set_column(w, w, len(colname[w])+2)
psworkbook.close()
asmpn = input('\nPRESS <ENTER> TO EXIT')
