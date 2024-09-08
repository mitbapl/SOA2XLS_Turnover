from flask import Flask, render_template, request, redirect, url_for, send_file
import pandas as pd
import numpy as np
import tabula
from tabula import read_pdf
import os
import math

app = Flask(__name__)
# Set the JAVA_HOME environment variable to the Java installation directory
os.environ["JAVA_HOME"] = '/opt/homebrew/opt/openjdk/libexec/openjdk.jdk'
# os.environ['JAVA_HOME'] = '/usr/lib/jvm/java-8-openjdk-amd64/jre/lib/amd64/server/libjvm.so'
os.environ['PATH'] = os.environ['JAVA_HOME'] + '/bin:' + os.environ['PATH']
app.config['DEBUG'] = True
app.config['UPLOAD_FOLDER'] = 'uploads/'  # Folder to store uploaded files
@app.errorhandler(500)
def internal_error(error):
    return "Internal Server Error", 500

# Helper Functions
def abc(a):
    if type(a) == str:
        if len(a.split(' ')) == 2:
            z = a.split(' ')[1]
        else:
            z = a.split(' ')[0]
    else:
        z = a
    return z

def isnan(value):
    try:
        return math.isnan(float(value))
    except:
        return False

# HDFC Processing Function
def process_hdfc(f):
    print(os.environ['JAVA_HOME'])
    print(os.environ['PATH'])
    try:
        pars = tabula.read_pdf(f,                                            
                               pages='all',
                               silent=True,
                               stream=True,
                               multiple_tables=True,
                               pandas_options={ 'header': None }) 

        df = pd.DataFrame()
        tables = []
        for i, c in enumerate(pars):
            if c.shape[1] == 7:
                tables.append(c)
            elif c.shape[1] == 6:
                c[6] = np.nan; c = c[[0,1,2,3,4,6,5]]; c.columns = range(c.shape[1])
                tables.append(c)
            elif c.shape[1] == 8:
                c = c[[0,1,3,4,5,6,7]]; c.columns = range(c.shape[1])
                tables.append(c)   
        df = pd.concat(tables, ignore_index=True)

        try:
            idx = [c for c in df[df.apply(lambda row: row.astype(str).str.lower().str.contains('balance').any(), axis=1) == True].index if c in df[df.apply(lambda row: row.astype(str).str.lower().str.contains('date').any(), axis=1) == True].index][0]
            df.columns = df.iloc[idx]; df = df.iloc[idx+1:,:]; df.reset_index(drop=True,inplace=True)           
        except:
            try:
                idx = [c for c in df[df.apply(lambda row: row.astype(str).str.lower().str.contains('balance').any(), axis=1) == True].index if c in df[df.apply(lambda row: row.astype(str).str.lower().str.contains('particular').any(), axis=1) == True].index][0]
                df.columns = df.iloc[idx]; df = df.iloc[idx+1:,:]; df.reset_index(drop=True,inplace=True)           
            except:
                print("\nHDFC-Column headers missing")
                pass
                
        try:
            idx2 = [c for c in df[df.apply(lambda row: row.astype(str).str.lower().str.contains('statement summary').any(),axis=1) == True].index][0]    
            df.drop(df.index[idx2:], inplace=True)
        except: pass

        df = df[~df.index.isin(df[df.apply(lambda row: row.astype(str).str.lower().str.contains('page:|account status|total|reason for return|inward clg|opening balance|statement of a/c|statement summary|generated on|generated by|computer generated statement|not').any(), axis=1) == True].index)]
        df.drop(df.nunique(dropna=False)[(df.nunique(dropna=False) == 1)].index, axis=1, inplace=True)             
        df.iloc[:,-1] = df.iloc[:,-1].fillna(df.iloc[:,-2])

        try:
            bal = [c for c in df.columns if "BALANCE" in str(c).upper()][0]
            df[bal] = df[bal].apply(lambda x: abc(x))
        except: 
            print("\nBalance columns missing")   

        df['flag'] = df.iloc[:,-1].shift(1)
        df = df[~df.index.isin(df[df.iloc[:,-1] == df.iloc[:,-2]].index)]

        try:
            dat = [c for c in df.columns if "TRANSACTION DATE" in str(c).upper()][0]
        except:
            try:
                dat = [c for c in df.columns if "TXN DATE" in str(c).upper()][0]
            except:
                try:
                    dat = [c for c in df.columns if "DATE" in str(c).upper()][0]
                except: pass

        try:
            chq = [c for c in df.columns if "CHQ" in str(c).upper()][0]
        except:
            try:
                chq = [c for c in df.columns if "CHEQUE" in str(c).upper()][0]
            except: pass

        try:
            narr = [c for c in df.columns if "REMARKS" in str(c).upper()][0]
        except:
            try:
                narr = [c for c in df.columns if "PARTICULARS" in str(c).upper()][0]
            except:
                try:
                    narr = [c for c in df.columns if "DESCRIPTION" in str(c).upper()][0]
                except:
                    try:
                        narr = [c for c in df.columns if "DETAILS" in str(c).upper()][0]
                    except:
                        try:
                            narr = [c for c in df.columns if "NARRATION" in str(c).upper()][0]
                        except: pass

        try:
            wdl = [c for c in df.columns if "WITHDRAW" in str(c).upper()][0]
        except:
            try:
                wdl = [c for c in df.columns if "AMOUNT" in str(c).upper()][0]
            except:
                try:
                    wdl = [c for c in df.columns if "DEBIT" in str(c).upper()][0]
                except: pass

        try:
            dep = [c for c in df.columns if "DEPOSIT" in str(c).upper()][0]
        except:
            try:
                dep = [c for c in df.columns if "CREDIT" in str(c).upper()][0]
            except: pass

        try:
            df[dep] = df[dep].apply(lambda x: x.split(' ')[0] if type(x) == str else x)
            df[wdl] = df[wdl].apply(lambda x: x.split(' ')[0] if type(x) == str else x)                       
            df['Wdl1'] = df[wdl].astype(str).apply(lambda x: str(x).replace(",","").replace("(Cr)","").replace("(Dr)","")).astype(float) * -1
            df['Wdl1'] = df['Wdl1'].fillna(df[dep].astype(str).apply(lambda x: str(x).replace(",","").replace("(Cr)","").replace("(Dr)","")).astype(float))                
        except: 
            try:
                Wdl1 = []
                for i, item in enumerate(df[wdl]):
                    try:
                        tmpp = float(str(item).replace(",","").replace("(Cr)","").replace("(Dr)","")) * -1
                    except ValueError:
                        df.iloc[i,df.columns.get_loc(wdl)-1] = df.iloc[i,df.columns.get_loc(wdl)]
                        df.iloc[i,df.columns.get_loc(wdl)] = df.iloc[i,df.columns.get_loc(dep)]
                        df.iloc[i,df.columns.get_loc(dep)] = df.iloc[i,df.columns.get_loc(bal)]
                        df.iloc[i,df.columns.get_loc(bal)] = df.iloc[i,df.columns.get_loc(bal)+1]
                    Wdl1.append(tmpp)  
                df[bal] = df[bal].fillna(df.iloc[:,df.columns.get_loc(bal)-1])
                df.drop(df.columns[df.columns.get_loc(bal)+1], axis=1, inplace=True)
                df['Wdl1'] = Wdl1   
                df['Wdl1'] = df['Wdl1'].fillna(df[dep].astype(str).apply(lambda x: str(x).replace(",","").replace("(Cr)","").replace("(Dr)","")).astype(float))                
            except: pass

        df = df.T.drop_duplicates().T           
        df[bal] = df[bal].apply(lambda x: str(x).replace(",","").replace("(Cr)","").replace("(Dr)","")).astype(float)                                 
        df['flag'] = df.iloc[:,0].astype(str) + df['Wdl1'].astype(str) + df[bal].astype(str)
        df['flag2'] = np.arange(len(df))

        df.loc[df[['flag']].duplicated(keep=False), 'flag'] = df['flag'] + df['flag2'].astype(str)  
        df['flag'] = df['flag'].apply(lambda row: np.nan if 'nannannan' in row else row).fillna(method='ffill')        

        df[narr] = df.groupby('flag')[narr].transform(lambda x: ' '.join(x))                
        df = df.drop_duplicates(['flag'], keep='first').iloc[0:,:-3].reset_index(drop=True)

        df = df.replace(r'^\s*$', np.nan, regex=True)

        if isnan(df[dep][0]) == False:
            df["Credits"] = np.nan
            df["Credits"][0] = float(str(df[dep][0]).replace(",","").replace("(Cr)","").replace("(Dr)",""))
            df["Debits"] = np.nan
        elif isnan(df[wdl][0]) == False:
            df["Credits"] = np.nan    
            df["Debits"] = np.nan
            df["Debits"][0] = float(str(df[wdl][0]).replace(",","").replace("(Cr)","").replace("(Dr)","")) * -1

        for i, j in enumerate(df[bal]):
            if i < len(df[bal])-1:
                if df[bal][i] < df[bal][i+1]:
                    df["Credits"][i+1] = df[bal][i+1] - df[bal][i]
                elif df[bal][i] > df[bal][i+1]:
                    df["Debits"][i+1] = df[bal][i+1] - df[bal][i]
            else:
                pass

        df_statement = df[[dat, chq, narr, "Debits", "Credits", bal]]
        df_statement.columns = ["Xns Date", "Cheque No", "Narration", "Debits", "Credits", "Balance"]
        
        # Turnover process
        if df.empty:
            raise ValueError("No data found in the PDF.")

        # Extract balances
        opening_balance = df.iloc[0][bal] if not df.empty else np.nan
        closing_balance = df.iloc[-1][bal] if not df.empty else np.nan

        # Calculate credit and debit sums
        credit_sum = df['Credits'].sum() if 'Credits' in df.columns else np.nan
        debit_sum = df['Debits'].sum() if 'Debits' in df.columns else np.nan

        # Count transactions
        no_of_cr_trans = df['Credits'].count()
        no_of_dr_trans = df['Debits'].count()

        # Calculate cash receipts and payments
        cash_receipts = df[df['Narration'].str.contains('cash', case=False, na=False)]['Credits'].sum()
        no_of_cash_receipts = df[df['Narration'].str.contains('cash', case=False, na=False)]['Credits'].count()
        cash_payments = df[df['Narration'].str.contains('cash', case=False, na=False)]['Debits'].sum()
        no_of_cash_payments = df[df['Narration'].str.contains('cash', case=False, na=False)]['Debits'].count()

        # Minimum and Maximum balance with dates
        min_balance = df[bal].min() if not df.empty else np.nan
        min_balance_date = df.loc[df[bal].idxmin(), dat] if not df.empty else np.nan
        max_balance = df[bal].max() if not df.empty else np.nan
        max_balance_date = df.loc[df[bal].idxmax(), dat] if not df.empty else np.nan

        # Example for Total Debits & Credits in 12-Month Parts
        df['Year'] = pd.to_datetime(df[dat]).dt.year
        total_debits_credits = df.groupby('Year').agg({'Debits': 'sum', 'Credits': 'sum'}).reset_index()

        # Example for Average Balance Calculation
        average_balances = {
            '1 Month': df[bal].rolling(window=30).mean().iloc[-1],
            '3 Months': df[bal].rolling(window=90).mean().iloc[-1],
            '6 Months': df[bal].rolling(window=180).mean().iloc[-1],
            '12 Months': df[bal].rolling(window=365).mean().iloc[-1],
        }

        # Check for bouncing entries
        bouncing_entries = df[df['Narration'].str.contains('bounced|failed|ecs|nach|emi|si', case=False, na=False)]

        # Identify repeated transactions
        repeated_transactions = df.groupby('Narration').filter(lambda x: len(x) > 1)

        # Quantum of Cash Receipts and Withdrawals
        significant_cash_receipts = df[df['Credits'] > 1000]  # threshold of 1000
        significant_cash_withdrawals = df[df['Debits'] > 1000]  # threshold of 1000

        # Summary of Repeated Payments/Receipts
        summary_repeated = df.groupby('Narration').agg({'Credits': 'sum', 'Debits': 'sum'}).reset_index()

        # Prepare the turnover data dictionary
        turnover_data = {
            "Metric": [
                "Opening Balance", 
                "Closing Balance", 
                "Credit Sum (Incl Cash)", 
                "Debit Sum (Incl Cash)", 
                "No Of Cr Trans", 
                "No Of Dr Trans", 
                "Cash Receipts", 
                "No Of Cash Receipts", 
                "Cash Payments", 
                "No Of Cash Payments", 
                "Minimum Balance", 
                "Min Balance Date", 
                "Maximum Balance", 
                "Max Balance Date"
            ],
            "Value": [
                opening_balance, 
                closing_balance, 
                credit_sum, 
                debit_sum, 
                no_of_cr_trans, 
                no_of_dr_trans, 
                cash_receipts, 
                no_of_cash_receipts, 
                cash_payments, 
                no_of_cash_payments, 
                min_balance, 
                min_balance_date, 
                max_balance, 
                max_balance_date
            ]
        }
        # Average balances
        average_balances_df = pd.DataFrame(average_balances.items(), columns=['Period', 'Average Balance'])
        average_balances_df.columns = ['Period', 'Average Balance']
        df_turnover = pd.DataFrame(turnover_data)
        final_turnover_data = pd.concat([df_turnover, average_balances_df], ignore_index=True)
        
        return df_statement, final_turnover_data

    except Exception as e:
        print("Error:", e)
        return None, None

# Flask Routes
@app.route('/')
def index():
    return render_template('/Index.html')

@app.route('/upload', methods=['POST'])
def upload_file():
    if request.method == 'POST':
        if 'file' not in request.files:
            return redirect(request.url)
        file = request.files['file']
        if file.filename == '':
            return redirect(request.url)
        if file:
            file_path = os.path.join(app.config['UPLOAD_FOLDER'], file.filename)
            file.save(file_path)
            print(file_path)
            df_statement, df_turnover = process_hdfc(file_path)
            if df_statement is not None:
                output_file = os.path.join(app.config['UPLOAD_FOLDER'], 'processed_hdfc.xlsx')
                
                # Save both DataFrames to the same Excel file, each in a separate sheet
                with pd.ExcelWriter(output_file) as writer:
                    df_statement.to_excel(writer, sheet_name='Statement Data', index=False)
                    df_turnover.to_excel(writer, sheet_name='Turnover Data', index=False)

                return send_file(output_file, as_attachment=True)
            else:
                return "Error in processing the file"
    return redirect(url_for('index'))

if __name__ == '__main__':
    if not os.path.exists(app.config['UPLOAD_FOLDER']):
        os.makedirs(app.config['UPLOAD_FOLDER'])
    app.run(debug=True)
