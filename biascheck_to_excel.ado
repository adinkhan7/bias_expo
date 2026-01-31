*! version 1.1.0 Adin Khan 31jan2026
capture program drop biascheck_to_excel
program define biascheck_to_excel
    version 17
    syntax varname, BY(varname) SAVING(string) SHEET(string)
    
    preserve
        * 1. Calculate Success Count per Enum (Flat logic to avoid r(621))
        tempvar total_c
        bysort `by': gen `total_c' = sum(consent == 1)
        bysort `by': replace `total_c' = `total_c'[_N]
        
        * 2. Create option dummies with metadata
        local vlab : value label `varlist'
        qui levelsof `varlist', local(values)
        
        local dvars ""
        foreach val of local values {
            local vname "`varlist'_`val'"
            gen `vname' = (`varlist' == `val') if !missing(`varlist')
            
            local label_text = cond("`vlab'" != "", "`: label `vlab' `val''", "`val'")
            label variable `vname' "`varlist': `label_text'"
            local dvars `dvars' `vname'
        }
        
        * 3. Collapse to get means AND the count
        collapse (mean) `dvars' (first) consented_count=`total_c', by(`by')
        
        * 4. Apply your specific percentage formatting logic
        foreach v of varlist `dvars' {
            local val = subinstr("`v'", "`varlist'_", "", .)
            local label_text = cond("`vlab'" != "", "`: label `vlab' `val''", "`val'")
            label variable `v' "`varlist': `label_text'"
            
            replace `v' = `v' * 100
            format `v' %9.0f
        }
        
        label variable consented_count "Total Consented Surveys"
        
        * 5. Final layout: Enumerator, then Count, then the Options
        order `by' consented_count `dvars'
        
        * 6. INTEGRATED EXPORT LOGIC (Formerly export_hfc)
        * This ensures the program is standalone
        foreach v of varlist _all {
            local lbl : variable label `v'
            if "`lbl'" != "" {
                label variable `v' "`v': `lbl'"
            }
            else {
                label variable `v' "`v'"
            }
        }

        export excel using `"`saving'"', ///
            sheet("`sheet'") sheetreplace firstrow(varlabels)
            
    restore
end