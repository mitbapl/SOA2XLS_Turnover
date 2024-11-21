from flask import Flask, render_template, request, redirect, url_for, send_file
import pandas as pd
import numpy as np
import tabula
from tabula import read_pdf
import os
import math

app = Flask(__name__)
# Set the JAVA_HOME environment variable to the Java installation directory
# os.environ["JAVA_HOME"] = '/opt/homebrew/opt/openjdk/libexec/openjdk.jdk'
# os.environ['JAVA_HOME'] = '/usr/lib/jvm/java-8-openjdk-amd64/jre/lib/amd64/server/libjvm.so'
#os.environ['PATH'] = os.environ['JAVA_HOME'] + '/bin:' + os.environ['PATH']
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
    try:
        # Read the PDF into tables using Tabula
        pars = tabula.read_pdf(f, pages='all', silent=True, stream=True, multiple_tables=True, pandas_options={'header': None})
        
        df = pd.DataFrame()
        tables = []
        for c in pars:
            if c.shape[1] in [6, 7, 8]:
                if c.shape[1] == 6:
                    c[6] = np.nan
                    c = c[[0, 1, 2, 3, 4, 6, 5]]
                elif c.shape[1] == 8:
                    c = c[[0, 1, 3, 4, 5, 6, 7]]
                tables.append(c)
        
        df = pd.concat(tables, ignore_index=True)

        # Process headers
        idx = [c for c in df[df.apply(lambda row: row.astype(str).str.lower().str.contains('balance').any(), axis=1) == True].index if c in df[df.apply(lambda row: row.astype(str).str.lower().str.contains('date').any(), axis=1) == True].index]
        if idx:
            idx = idx[0]
            df.columns = df.iloc[idx]
            df = df.iloc[idx + 1:, :].reset_index(drop=True)

        # Remove irrelevant rows
        irrelevant_keywords = ['page:', 'account status', 'total', 'reason for return', 'inward clg', 'opening balance', 'statement of a/c', 'statement summary', 'generated on', 'generated by', 'computer generated statement', 'not']
        df = df[~df.apply(lambda row: row.astype(str).str.lower().str.contains('|'.join(irrelevant_keywords)).any(), axis=1)]
        df.drop(df.nunique(dropna=False)[df.nunique(dropna=False) == 1].index, axis=1, inplace=True)

        # Process columns
        try:
            bal_col = [col for col in df.columns if "BALANCE" in str(col).upper()][0]
            df[bal_col] = df[bal_col].apply(lambda x: abc(x))
        except:
            raise ValueError("Balance column missing")

        dat_col = [col for col in df.columns if "DATE" in str(col).upper()][0]
        narr_col = [col for col in df.columns if "NARRATION" in str(col).upper() or "PARTICULARS" in str(col).upper()][0]
        wdl_col = [col for col in df.columns if "DEBIT" in str(col).upper()][0]
        dep_col = [col for col in df.columns if "CREDIT" in str(col).upper()][0]

        # Convert transaction amounts
        df[dep_col] = pd.to_numeric(df[dep_col].replace(",", "", regex=True), errors='coerce')
        df[wdl_col] = pd.to_numeric(df[wdl_col].replace(",", "", regex=True), errors='coerce')

        # Calculate average balance
        avg_balance = df[bal_col].mean()

        # Prepare SOA ledger (Statement sheet)
        df_statement = df[[dat_col, narr_col, wdl_col, dep_col, bal_col]]
        df_statement.columns = ["Transaction Date", "Narration", "Debit", "Credit", "Balance"]

        # Bounced Transactions sheet
        bounce_keywords = ['bounced', 'returned', 'insufficient funds', 'nach', 'ecs', 'ach']
        df_bounced = df[df[narr_col].str.contains('|'.join(bounce_keywords), case=False, na=False)]

        # Repeated Transactions sheet
        repeated_keywords = ['emi', 'rent', 'utility', 'insurance']
        df_repeated = df[df[narr_col].str.contains('|'.join(repeated_keywords), case=False, na=False)]

        # Above Average Transactions sheet
        df_above_avg = df[(df[wdl_col] > avg_balance) | (df[dep_col] > avg_balance)]
        df_above_avg = df_above_avg[[dat_col, narr_col, wdl_col, dep_col, bal_col]]
        df_above_avg.columns = ["Transaction Date", "Narration", "Debit", "Credit", "Balance"]

        # Save to Excel
        output_path = 'HDFC_Statement_Analysis.xlsx'
        with pd.ExcelWriter(output_path) as writer:
            df_statement.to_excel(writer, sheet_name='Statement', index=False)
            df_bounced.to_excel(writer, sheet_name='Bounced Transactions', index=False)
            df_repeated.to_excel(writer, sheet_name='Repeated Transactions', index=False)
            df_above_avg.to_excel(writer, sheet_name='Above Avg Transactions', index=False)

        return output_path

    except Exception as e:
        print(f"Error: {e}")
        return None


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

                # Adding your name to the last row as an author
                # author_row = pd.DataFrame({"Author": ["Prashant L. Mitba"]})  # Create a DataFrame for the author
                # df = pd.concat([df, author_row], ignore_index=True)  # Append the author DataFrame
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
    app.run(host='0.0.0.0', port=5000)
