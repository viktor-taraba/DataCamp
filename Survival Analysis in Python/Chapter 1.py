# Create a function to return 1 if observed 0 otherwise
def check_observed(row):
    if pd.isna(row['birth_date']):
        flag = 0
    elif pd.isna(row['death_date']):
        flag = 0
    else:
        flag = 1
    return flag
  
# Create a censorship flag column
dolphin_df["observed"] = dolphin_df.apply(check_observed, axis=1)

# Print average of observed
print(np.average(dolphin_df["observed"]))

# Print first row
print(regime_durations.head(1))

# Count censored data
count = len(regime_durations[regime_durations["observed"] == 0])

# Print the count to console
print(count)
