capt program drop KP_stat
program KP_stat, eclass
	version 12
	syntax varlist [if] [in] [, end(varlist) iv(varlist) CORRECclus(real 1) ]
	local depvar: word 1 of `varlist'
	local regs: list varlist - depvar
	marksample touse
	tempname b V VCVb_fs
	

mata: st_view(y=., ., "`depvar'")
mata: st_view(X=., ., "`regs'")
mata: st_view(Z=., ., "`iv'")
mata: st_view(Y=., ., "`end'")

mata: Nend = cols(Y)
mata: Niv = cols(Z)

mata: cluster= I(rows(Y))+adjacency

* Partial out X, p refers to partialling out
mata: X = (X, J(rows(Y),1,1))
mata: MX = I(rows(X))-X*invsym(X'X)*X'
mata: Zp = MX * Z
mata: Yp = MX * Y
mata: yp = MX * y


* VCV first stage parameters
mata: VZp = invsym(Zp'Zp)*Zp'
mata: b_fs = VZp * Yp
mata: PZp = Zp * VZp
mata: MZp = I(rows(Zp)) - PZp
mata: u = MZp * Yp
mata: VCVu = (vec(u)*vec(u)') :* (J(Nend,Nend,1)#cluster) 
mata: VCVb_fs = (I(Nend)#VZp) * VCVu * (I(Nend)#VZp)'
* finite sample adjustment
mata: N = rows(Yp)
mata: K = cols(X)+cols(Zp)
mata: f = N/(N-K)
mata: VCVb_fs = f * VCVb_fs
mata: _makesymmetric(VCVb_fs)

* Build Below the Asymptotic VCE from the VCE 
* See page 12 of the the slide show http://www.stata.com/meeting/uk14/abstracts/materials/uk14_schaffer.pdf
mata: Sz = 1/sqrt(N)*Zp'
mata: AVCVb_fs = (`correcclus'/(`correcclus' -1))*(I(Nend)#Sz) * VCVu * (I(Nend)#Sz)'

mata: st_matrix("r(VCVb_fs)", VCVb_fs)
mat VCVb_fs=r(VCVb_fs)

mata: st_matrix("r(AVCVb_fs)", AVCVb_fs)
mat AVCVb_fs=r(AVCVb_fs)


* Stata convention is to exclude constant from instrument list
* Need word option so that varnames with "_cons" in them aren't zapped
qui count
local N = r(N)
local iv_ct : word count `iv'
local iv_ct  = `iv_ct' + 1
local sdofminus = 0
local partial_ct : word count `regs'
local partial_ct = `partial_ct' + 1
local sdofminus =`sdofminus'+`partial_ct'
local N_clust=1000000
local exex1_ct     : word count `iv'
local noconstant ""
local robust "robust"
local CLUS="AVCVb_fs"



*Need only test of full rank 
nwRanktest_mt (`end') (`iv') , vb("`CLUS'") partial(`regs') full wald `noconstant' `robust'

* sdofminus used here so that F-stat matches test stat from regression with no partial
scalar Chi2=r(chi2)
scalar rkf=r(chi2)/(`N'-1) *(`N'-`iv_ct'-`sdofminus')  *(`N_clust'-1)/`N_clust' /`exex1_ct'
				
scalar widstat=rkf
scalar KPstat=widstat			
end

