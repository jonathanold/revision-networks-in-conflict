capt program drop nw2sls
program nw2sls, eclass
	version 12
	syntax varlist [if] [in] [, end(varlist) iv(varlist) ]
	local depvar: word 1 of `varlist'
	local regs: list varlist - depvar
	marksample touse
	tempname b V
	


mata: st_view(Y=., ., "`depvar'")
mata: st_view(X=., ., "`end' `regs'")
mata: X=(X, J(rows(Y),1,1))
mata: st_view(Z=., ., "`iv' `regs'")
mata: Z=(Z, J(rows(Y),1,1))

mata: st_view(Xe=., ., "`end'")
mata: Nend = cols(Xe)

mata: st_view(Ze=., ., "`iv'")
mata: Niv = cols(Ze)


* 2SLS: parameters
mata: W=invsym(Z'Z)
mata: P=invsym(X'Z * W * Z'X)* X'Z * W *Z'
mata: b=P*Y
mata: res = Y-X*b
mata: resmat = res * res'
mata: N=rows(res)

* clustering
* network
mata: cluster= I(rows(Y))+adjacency

* VCV of errors
mata: omega = resmat :* cluster

* 2SLS: VCV
mata: V=P*omega*P'
mata: _makesymmetric(V)


* export
mata: b=b'
mata: st_matrix("r(V)", V)
mata: st_matrix("r(b)", b)
mata: st_numscalar("r(N)", N)


	mat `b'=r(b)
	mat `V'=r(V)
	matname `V' "`end' `regs' _cons"
	mat colnames `b' = `end' `regs' _cons

    ereturn post `b' `V'
	ereturn local depvar "`depvar'"
	ereturn scalar N=r(N)
    ereturn local cmd "nw2sls"
    
    ereturn display
	

end
