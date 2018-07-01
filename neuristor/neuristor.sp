
***************************

.subckt memristor plus minus Ron=100 Roff=10k Rini=5k
.param uv=10f D=10n k='uv*Ron/D**2' a='(Rini-Ron)/(Roff-Rini)'

Rmem plus minus R='Roff + (Ron-Roff)/(1 + a * exp(-4 * k * V(q)))'
Gx 0 Q cur='i(Rmem)'
Cint Q 0 1
Raux Q 0 100meg

.ends memristor

***************************

.options post=2 lvltim=1 method=gear
VS1 VIN  gnd pulse( 0 1 0m 0.1n 0.1n 1m 10m )
VS2 VDC1 gnd dc -0.9
VS3 VDC2 gnd dc 0.9

***************************

X1 V1 VDC1 memristor
X2 V2 VDC2 memristor

C1 V1 VDC1 3n
C2 V2 VDC2 2n

R1 VIN V1 100k
R2 V1 V2  100k
RL V2 gnd 1meg

***************************

.tran 0.1m 100m
.probe v(x*.*) i(x*.*)
.end
