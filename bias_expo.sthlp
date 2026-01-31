---

# bias_expo

**Author:** Adin Khan

**Category:** Data Quality / High-Frequency Checks (HFC)

### Overview

`bias_expo` is a Stata utility designed to automate the detection of enumerator bias during field surveys. It takes a categorical variable (e.g., a Likert scale or a 'Yes/No' question) and generates a proportion-based balance table, exporting it directly to a formatted Excel sheet.

### Key Features

* **Automated Dummy Generation:** Dynamically creates dummies for all categories in your variable.
* **Success Tracking:** Automatically calculates and includes a column for "Total Consented Surveys" per enumerator to provide sample size context.
* **High-Fidelity Labels:** Integrates variable names with their value labels (e.g., `q9a: Very Important`) as Excel headers.
* **Ready-to-Present:** Converts proportions to whole-number percentages (e.g., 55 instead of 0.55) for immediate use in dashboards or reports.

---

### Syntax

```stata
bias_expo varname, by(groupvar) saving("filename.xlsx") sheet("sheetname")

Example:
bias_expo q9a,  by(enum) saving("q9a_bias.xlsx")  sheet("q9a")

For Several variables:

local vars (varname)
local excel_file "Bias_Check_Report_`c(current_date)'.xlsx"

foreach v of local vars {
    di "System: Exporting biascheck for `v'..."
    
    * This runs the check and saves it to a sheet named after the variable
    bias_expo `v', by(varname) saving("`excel_file'") sheet("`v'")
}


Example:
local vars q8a_old q8b_old q8c_old q8d q9a q9b q10a q10b town_hall_decision signup involvement
local excel_file "Bias_Check_Report_`c(current_date)'.xlsx"

foreach v of local vars {
    di "System: Exporting biascheck for `v'..."
    
    * This runs the check and saves it to a sheet named after the variable
    bias_expo `v', by(enum_lab) saving("`excel_file'") sheet("`v'")
}


```

* `varname`: The categorical variable you want to check for bias (e.g., `q10_satisfaction`).
* `by()`: The grouping variable, typically your enumerator ID or name variable.
* `saving()`: The path and name of the Excel file.
* `sheet()`: The specific sheet name within the Excel file.

---

### Example

If you want to check if certain enumerators are over-reporting "Very Important" for question `q9a`:

```stata
local excel_file "Enumerator_Bias_Report.xlsx"

biascheck_to_excel q9a, by(enum_name) saving("`excel_file'") sheet("q9a_check")

```

**Output in Excel:**
| enum_name | Total Consented Surveys | q9a: Very Important | q9a: Important | q9a: Unimportant |
| :--- | :--- | :--- | :--- | :--- |
| Abu Bakar | 45 | 60 | 30 | 10 |
| Al Kabir | 12 | 20 | 50 | 30 |

---

### Requirements

* Stata 17 or higher.
* A variable named `consent` (1 = Consented, 0 = Not) must exist in the dataset to calculate the success counts.

---

### Why this is better than manual `tabstat`

1. **Repeatable:** Running this in a loop for 50 variables takes seconds; manual copy-pasting takes hours.
2. **Deterministic:** Eliminates human error in transferring numbers from the Stata results window to Excel.

3. **Label Retention:** Unlike standard Stata export commands, this preserves the descriptive text of your survey options.
=======
3. **Label Retention:** Unlike standard Stata export commands, this preserves the descriptive text of your survey options.


