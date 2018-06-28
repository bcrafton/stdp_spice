
.subckt memristorR1 plus minus Ron=100 Roff=10k Rini=5k
.param uv=10f D=10n k='uv*Ron/D**2' a='(Rini-Ron)/(Roff-Rini)'

* Rmem plus minus R='Roff + (Ron-Roff)/(1 + a * exp(-4 * k * V(q)))'
Roff plus aux 'Roff'
Eres aux minus vol='(Ron-Roff)/(1+a*exp(-4*k*V(q)))*I(Eres)'

* Gx 0 Q cur='i(Rmem)'
Gx 0 Q cur='i(Roff)'
Cint Q 0 1
Raux Q 0 100meg

.ends memristorR1

.options post=2 runlvl=0 lvltim=1 method=gear
Vin in gnd SIN(0, 1, 1, 0, 0, 0)
Xmem in gnd memristorR1
.tran 0.1m 10
.probe v(x*.*) i(x*.*)
.end
