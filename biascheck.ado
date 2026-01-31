*! version 1.2.0 Adin Khan 31jan2026
capture program drop biascheck_to_excel
program define biascheck_to_excel
    version 17
    syntax varlist(min=1), BY(varname) SAVING(string) SHEET(string)
    
    preserve
        * 1. Calculate Success Count per Enum 
        tempvar total_c
        bysort `by': gen `total_c' = sum(consent == 1)
        bysort `by': replace `total_c' = `total_c'[_N]
        
        * 2. Identify if it is a single variable or a group (multiple choice)
        local count : word count `varlist'
        
        if `count' == 1 {
            * Logic for Single Select (Same as before)
            local vlab : value label `varlist'
            qui levelsof `varlist', local(values)
            local dvars ""
            foreach val of local values {
                local vname "v_`val'" // Use generic temp name to avoid conflicts
                gen `vname' = (`varlist' == `val') if !missing(`varlist')
                local label_text = cond("`vlab'" != "", "`: label `vlab' `val''", "`val'")
                label variable `vname' "`varlist': `label_text'"
                local dvars `dvars' `vname'
            }
        }
        else {
            * Logic for Multiple Select (c4_1, c4_2...)
            local dvars `varlist'
        }
        
        * 3. Collapse to get means AND the count
        collapse (mean) `dvars' (first) consented_count=`total_c', by(`by')
        
        * 4. Percentage formatting
        foreach v of varlist `dvars' {
            replace `v' = `v' * 100
            format `v' %9.0f
        }
        
        label variable consented_count "Total Consented Surveys"
        order `by' consented_count `dvars'
        
        * 5. Labeling Loop (Integrated Export Logic)
        foreach v of varlist _all {
            local lbl : variable label `v'
            if "`lbl'" != "" {
                label variable `v' "`v': `lbl'"
            }
            else {
                label variable `v' "`v'"
            }
        }

        export excel using `"`saving'"', sheet("`sheet'") sheetreplace firstrow(varlabels)
    restore
end