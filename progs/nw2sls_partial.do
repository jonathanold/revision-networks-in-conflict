capt program drop nw2sls_partial
program nw2sls_partial, eclass
	version 12
	syntax varlist [if] [in] [, end(varlist) iv(varlist) CORRECclus(real 1) ]
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

mata: st_view(ym=., ., "`depvar'")
mata: st_view(Xm=., ., "`regs'")
mata: st_view(Zm=., ., "`iv'")
mata: st_view(Ym=., ., "`end'")
* Partial out X, p refers to partialling out
mata: MXm = I(rows(Xm))-Xm*invsym(Xm'Xm)*Xm'
mata: Zp = MXm * Zm
mata: Yp = MXm * Ym
mata: yp = MXm * ym

 
* 2SLS: parameters
mata: W=invsym(Zp'Zp)
mata: P=invsym(Yp'Zp * W * Zp'Yp)* Yp'Zp * W *Zp'
mata: b=P*yp
mata: res = yp-Yp*b
mata: resmat = res * res'
mata: N=rows(res)


mata: cluster= I(rows(Y))+adjacency

* VCV of errors
mata: omega = resmat :* cluster



* start Hansen J
mata: J = cols(Z)-cols(X)
mata: WaWa=   Zp' *  omega * Zp 
mata: Hansen =  res' * Zp  *invsym(Zp' *  omega * Zp )* Zp'res  
mata: pValueHansen = 1-chi2(J, Hansen)
mata: st_numscalar("r(Hansen)", Hansen)
mata: st_numscalar("r(pValueHansen)", pValueHansen)
* end of Hansen *

* 4 step GMM 
mata: W2=invsym((1/N)* Zp'* omega  * Zp)
mata: P2=invsym(Yp'Zp * W2 * Zp'Yp)* Yp'Zp * W2 *Zp'
mata: b2=P2*yp
mata: res2 = yp-Yp*b2
mata: resmat2 = res2 * res2'
mata: omega2 = resmat2 :* cluster
mata: Hansen =  res2' * Zp  *invsym(Zp' *  omega2  * Zp)* Zp' *res2   
mata: W3=invsym((1/N)* Zp'* omega2  * Zp)
mata: P3=invsym(Yp'Zp * W3 * Zp'Yp)* Yp'Zp * W3 *Zp'
mata: b3=P3*yp
mata: res3 = yp-Yp*b3
mata: resmat3 = res3 * res3'
mata: omega3 = resmat3 :* cluster
mata: Hansen =  res3' * Zp  *invsym(Zp' *  omega3  * Zp)* Zp' *res3
mata: W4=invsym((1/N)* Zp'* omega3  * Zp)
mata: P4=invsym(Yp'Zp * W4 * Zp'Yp)* Yp'Zp * W4 *Zp'
mata: b4=P4*yp
mata: res4 = yp-Yp*b4
mata: resmat4 = res4 * res4'
mata: omega4 = resmat4 :* cluster
mata: Hansen =  res4' * Zp  *invsym(Zp' *  omega4  * Zp)* Zp' *res4   
mata: pValueHansen = 1-chi2(J, Hansen)
mata: st_numscalar("r(Hansen)", Hansen)
mata: st_numscalar("r(pValueHansen)", pValueHansen)


* 2SLS: VCV
 
mata: V=(`correcclus'/(`correcclus' -1))*P*omega*P'
mata: _makesymmetric(V)

 
* export
mata: b=b'
mata: st_matrix("r(V)", V)
mata: st_matrix("r(b)", b)
mata: st_numscalar("r(N)", N)


	mat `b'=r(b)
	mat `V'=r(V)
	matname `V' "`end' 
	mat colnames `b' = `end'

    ereturn post `b' `V'
	ereturn local depvar "`depvar'"
	ereturn scalar N=r(N)
    ereturn local cmd "nw2sls_partial"
 	ereturn scalar pValueHansen = r(pValueHansen)
 	ereturn scalar Hansen = r(Hansen)
    ereturn display
	

end
