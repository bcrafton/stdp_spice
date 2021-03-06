
.subckt memristorR1 plus minus Ron=100 Roff=10k Rini=5k
.param uv=10f D=10n k='uv*Ron/D**2' a='(Rini-Ron)/(Roff-Rini)'

Rmem plus minus R='Ron * (V(Q) / D) + Roff * (1 - (V(Q) / D))'

Gx 0 Q cur='uv * Ron * i(Rmem) / D * (1 - pow(( 2 * V(Q)/D), 2))'

Cint Q 0 1
Raux Q 0 100meg

.ends memristorR1

.options post=2 runlvl=0 lvltim=1 method=gear

Vin in gnd pulse( 0 1 0m 0.1n 0.1n 1m 10m )

Xmem in gnd memristorR1
.tran 0.1m 20
.probe v(x*.*) i(x*.*)
.end
