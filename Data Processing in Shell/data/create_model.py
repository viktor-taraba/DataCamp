import io
import pandas as pd
import pickle
from sklearn.ensemble import RandomForestClassifier

# --- Fix malformed trainexit.csv ---
# Every data row in the source file is wrapped in an extra pair of double
# quotes (e.g. `"1,0,3,""Braund, Mr...""..."`), which makes pandas treat
# each row as a single field instead of 12 separate columns. This strips
# the outer quote wrapping and un-escapes the doubled inner quotes before
# handing the text to pandas.
fixed_lines = []
with open("trainexit.csv", "r", encoding="utf-8", newline="") as f:
    fixed_lines.append(f.readline().strip())  # header is fine as-is
    for line in f:
        line = line.rstrip("\r\n")
        if line.startswith('"') and line.endswith('"'):
            line = line[1:-1].replace('""', '"')
        fixed_lines.append(line)

df_train = pd.read_csv(io.StringIO("\n".join(fixed_lines)))

df_train.dropna(inplace=True)
df_train = df_train.drop(['PassengerId', 'Name', 'Cabin', 'Ticket'], axis=1)

df_train = pd.get_dummies(df_train)
df_train = df_train.drop(['Sex_female', 'Embarked_C_C'], axis=1, errors='ignore')
df_train = df_train.drop(['Sex_female'], axis=1, errors='ignore')

X = df_train.drop('Survived', axis=1)
y = df_train['Survived']

model = RandomForestClassifier()
model.fit(X, y)

model_filename = 'model.pkl'
with open(model_filename, 'wb') as f:
    pickle.dump(model, f)

print(f"Trained on {X.shape[0]} rows, {X.shape[1]} features -> {model_filename}")